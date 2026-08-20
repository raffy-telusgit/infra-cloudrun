# Issue Triage Agent: Cloud Build relay.
#
# GitHub Actions (on `issues: labeled`) cannot authenticate to GCP in this
# org (WIF pool creation is denied by org policy, and static SA keys are
# not to be created either). So GitHub Actions never talks to GCP: it only
# pushes a small trigger file to the `issue-triage` branch using its own
# ambient github.token. That push fires this Cloud Build trigger (the same
# GitHub-App-based mechanism already used for every other pipeline here),
# and Cloud Build - already a trusted GCP identity - does the actual work:
# read the KB docs from its own checkout, call FueliX, and post the GitHub
# comment using a PAT stored in Secret Manager.

resource "google_secret_manager_secret" "fuelix_api_key" {
  project   = var.project_id
  secret_id = "issue-triage-agent-fuelix-api-key"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "github_token" {
  project   = var.project_id
  secret_id = "issue-triage-agent-github-token"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_iam_member" "cloudbuild_fuelix_accessor" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.fuelix_api_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.project_number}@cloudbuild.gserviceaccount.com"
}

resource "google_secret_manager_secret_iam_member" "cloudbuild_github_token_accessor" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.github_token.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.project_number}@cloudbuild.gserviceaccount.com"
}

resource "google_cloudbuild_trigger" "issue_triage" {
  project  = var.project_id
  name     = "issue-triage-agent"
  location = var.region

  github {
    owner = var.github_owner
    name  = var.github_repo

    push {
      branch = "^issue-triage$"
    }
  }

  filename = "cloudbuild-issue-triage.yaml"
}
