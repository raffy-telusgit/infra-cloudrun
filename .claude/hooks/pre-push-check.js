#!/usr/bin/env node
/**
 * Claude Code PreToolUse hook: FueliX advisory review on git push.
 *
 * Fires on every Bash tool call. If the command is a `git push`, sends the
 * diff being pushed to FueliX (OpenAI-compatible) for an intelligent code
 * review. Behaviour:
 *   - No findings / skipped / errored → advisory `systemMessage`, push proceeds.
 *   - Findings flagged → returns permissionDecision "ask", so Claude Code shows
 *     the findings and prompts the user to Allow (push anyway) or Deny (block).
 * The hook itself never auto-blocks; the human always decides. Separate blocking
 * lint/format/terraform checks live in each repo's .githooks/ directory and run
 * on the actual `git push` (for both Claude and manual human pushes).
 *
 * Env vars:
 *   FUELIX_API_KEY   Required to enable the review (otherwise skipped silently)
 *   FUELIX_BASE_URL  Default: https://api.fuelix.ai/v1
 *   FUELIX_MODEL     Default: claude-sonnet-4
 *
 * Note: NODE_USE_ENV_PROXY=1 is set below so Node's built-in fetch honours
 * HTTP_PROXY / HTTPS_PROXY — required on the TELUS corporate network.
 */

"use strict";

// Must be set before the first fetch() so undici's dispatcher picks it up.
if (!process.env.NODE_USE_ENV_PROXY) {
  process.env.NODE_USE_ENV_PROXY = "1";
}

const fs = require("fs");
const path = require("path");

/**
 * Emit a non-blocking message that is VISIBLE to the user in the terminal.
 * PreToolUse hooks that exit 0 have their stderr hidden in the normal view, so
 * advisory output must be sent as a top-level `systemMessage` on stdout instead.
 * We deliberately do NOT set permissionDecision — this hook matches every Bash
 * command, and "allow" would auto-approve all of them.
 */
function emitUserMessage(message) {
  if (!message) return;
  try {
    process.stdout.write(JSON.stringify({ systemMessage: message }));
  } catch {
    /* ignore */
  }
}

const FUELIX_BASE_URL = process.env.FUELIX_BASE_URL || "https://api.fuelix.ai/v1";
const FUELIX_MODEL = process.env.FUELIX_MODEL || "claude-sonnet-4";
const MAX_DIFF_CHARS = 60000;

/** Read all of stdin synchronously. Avoids a Windows libuv race on exit. */
function readStdin() {
  try {
    return fs.readFileSync(0, "utf8");
  } catch {
    return "";
  }
}

/** True if the command looks like a `git push` invocation. */
function isGitPush(command) {
  if (typeof command !== "string") return false;
  return /(^|[;&|]|\bcd\b[^;&|]*?(?:;|&&|\|\|)\s*)\s*git\b[^;&|]*\bpush\b/.test(command);
}

/** Best-effort: find the git repo root the push targets. */
function resolveRepoDir(command, cwd) {
  let base = cwd && fs.existsSync(cwd) ? cwd : process.cwd();
  const cdMatch = command.match(/\bcd\s+("([^"]+)"|'([^']+)'|([^\s;&|]+))/);
  if (cdMatch) {
    const target = cdMatch[2] || cdMatch[3] || cdMatch[4];
    if (target) {
      const resolved = path.isAbsolute(target) ? target : path.resolve(base, target);
      if (fs.existsSync(resolved)) base = resolved;
    }
  }
  let dir = base;
  while (true) {
    if (fs.existsSync(path.join(dir, ".git"))) return dir;
    const parent = path.dirname(dir);
    if (parent === dir) return base;
    dir = parent;
  }
}

/** Run a shell command; returns { ok, output }. */
function run(cmd, cwd) {
  const { execSync } = require("child_process");
  try {
    const output = execSync(cmd, {
      cwd,
      stdio: ["ignore", "pipe", "pipe"],
      encoding: "utf8",
      env: process.env,
    });
    return { ok: true, output };
  } catch (err) {
    return { ok: false, output: `${err.stdout || ""}${err.stderr || ""}`.trim() || err.message };
  }
}

/** Compute the diff that is about to be pushed. */
function getPushDiff(repoDir) {
  const upstream = run("git rev-parse --abbrev-ref --symbolic-full-name @{u}", repoDir);
  const range = upstream.ok && upstream.output.trim()
    ? `${upstream.output.trim()}...HEAD`
    : "HEAD~1..HEAD";
  const diff = run(
    `git diff ${range} -- . ":(exclude)*.lock.hcl" ":(exclude)package-lock.json"`,
    repoDir,
  );
  return diff.ok ? diff.output : "";
}

/**
 * LLM review via FueliX. Never throws, never exits non-zero.
 * Returns { message, ask }:
 *   ask=false → advisory only, shown via systemMessage, push proceeds normally.
 *   ask=true  → findings were flagged; the user is prompted to Allow/Deny the push.
 */
async function agenticReview(repoDir, repoName) {
  if (!process.env.FUELIX_API_KEY) {
    return { message: "[pre-push] review skipped: FUELIX_API_KEY not set.", ask: false };
  }
  let diff = getPushDiff(repoDir);
  if (!diff.trim()) {
    return { message: "[pre-push] review skipped: no diff to review.", ask: false };
  }
  let truncated = false;
  if (diff.length > MAX_DIFF_CHARS) {
    diff = diff.slice(0, MAX_DIFF_CHARS);
    truncated = true;
  }

  const system =
    "You are a senior code reviewer for a TELUS Cloud Run / Terraform project. " +
    "Review the provided git diff for real problems only: logic bugs, security issues, " +
    "leaked secrets, risky IAM/networking changes, and clearly misleading names. " +
    "Be concise and skip nitpicks already handled by linters/formatters. " +
    'Respond ONLY with JSON: {"findings":[{"severity":"high|medium|low","file":"path","note":"..."}]}. ' +
    "Return an empty findings array if the diff looks fine.";
  const user =
    `Repository: ${repoName}\n` +
    (truncated ? "(diff truncated for length)\n" : "") +
    "\nGit diff:\n```diff\n" + diff + "\n```";

  let json;
  try {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), 30000);
    const res = await fetch(`${FUELIX_BASE_URL}/chat/completions`, {
      method: "POST",
      signal: controller.signal,
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${process.env.FUELIX_API_KEY}`,
        Connection: "close",
      },
      body: JSON.stringify({
        model: FUELIX_MODEL,
        temperature: 0,
        messages: [
          { role: "system", content: system },
          { role: "user", content: user },
        ],
      }),
    });
    clearTimeout(timer);
    if (!res.ok) {
      const body = await res.text().catch(() => "");
      return {
        message: `[pre-push] review skipped: FueliX returned ${res.status}. ${body.slice(0, 300)}`,
        ask: false,
      };
    }
    json = await res.json();
  } catch (err) {
    return { message: `[pre-push] review skipped: ${err.message}`, ask: false };
  }

  const content = json?.choices?.[0]?.message?.content || "";
  let findings = [];
  try {
    const match = content.match(/\{[\s\S]*\}/);
    findings = match ? JSON.parse(match[0]).findings || [] : [];
  } catch {
    // Unparseable response — surface it as advisory text, don't prompt.
    return content.trim()
      ? { message: `[pre-push] 🤖 FueliX review:\n${content.trim()}`, ask: false }
      : { message: "", ask: false };
  }

  if (!findings.length) {
    return { message: "[pre-push] 🤖 FueliX review: no issues flagged. ✅", ask: false };
  }

  const order = { high: 0, medium: 1, low: 2 };
  findings.sort((a, b) => (order[a.severity] ?? 3) - (order[b.severity] ?? 3));
  let out = "[pre-push] 🤖 FueliX flagged the following — Allow to push anyway, or Deny to block:\n";
  for (const f of findings) {
    const sev = String(f.severity || "info").toUpperCase();
    out += `  • [${sev}] ${f.file || "?"}: ${f.note || ""}\n`;
  }
  return { message: out.trimEnd(), ask: true };
}

async function main() {
  let raw = readStdin();
  if (raw.charCodeAt(0) === 0xfeff) raw = raw.slice(1);
  let payload = {};
  try {
    payload = JSON.parse(raw || "{}");
  } catch {
    process.exitCode = 0;
    return;
  }

  if (payload.tool_name !== "Bash") { process.exitCode = 0; return; }
  const command = payload.tool_input?.command || "";
  if (!isGitPush(command)) { process.exitCode = 0; return; }

  const repoDir = resolveRepoDir(command, payload.cwd);
  const repoName = path.basename(repoDir);

  const { message, ask } = await agenticReview(repoDir, repoName);

  if (ask && message) {
    // Findings flagged: show them and let the user decide (Allow = push, Deny = block).
    process.stdout.write(
      JSON.stringify({
        hookSpecificOutput: {
          hookEventName: "PreToolUse",
          permissionDecision: "ask",
          permissionDecisionReason: message,
        },
        systemMessage: message,
      }),
    );
  } else {
    // Advisory only — visible to the user, push proceeds normally.
    emitUserMessage(message);
  }

  process.exitCode = 0;
}

main().catch((err) => {
  process.stderr.write(`[pre-push] hook error (ignored): ${err.message}\n`);
  process.exitCode = 0;
});
