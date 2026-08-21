# issue-triage-agent

Provisions the GCP side of the issue-triage relay: the Cloud Build trigger
that watches `hello-world-app`'s `issue-triage` branch, and the two Secret
Manager secrets it reads from (`issue-triage-agent-fuelix-api-key`,
`issue-triage-agent-github-token`).

The actual agent logic — the GitHub Actions relay workflow, the
`cloudbuild-issue-triage.yaml` build config, and the Python script that
calls FueliX and posts the comment — lives in `hello-world-app`, not here.

For the full design (why there's no Cloud Run service, why GitHub Actions
never authenticates to GCP, and the hop-by-hop walkthrough), see
[`ARCHITECTURE.md` in `hello-world-app`](https://github.com/raffy-telusgit/hello-world-app/blob/main/ARCHITECTURE.md).

## What this module creates

- `google_cloudbuild_trigger.issue_triage` — fires on push to `issue-triage`
- `google_secret_manager_secret.fuelix_api_key` / `.github_token` — containers only; values are added out-of-band via `gcloud secrets versions add`, never through Terraform
- `google_secret_manager_secret_iam_member` × 2 — grants the Cloud Build default service account `roles/secretmanager.secretAccessor` on both secrets

## A gotcha if you touch this module again

Granting `secretmanager.secretAccessor` on a *specific* secret is a
resource-level IAM call (`secretmanager.secrets.setIamPolicy`), which
`roles/editor` doesn't include — Cloud Build's own apply will fail on it.
If you add a new secret here, the fix is: grant it once out-of-band from an
account holding `roles/secretmanager.admin`, then `terraform import` it so
Cloud Build's future applies see it as already satisfied. Full detail in
the architecture doc linked above.
