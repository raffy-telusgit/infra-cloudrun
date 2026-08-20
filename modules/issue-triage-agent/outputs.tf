output "fuelix_secret_id" {
  description = "Secret Manager secret ID holding the FueliX API key"
  value       = google_secret_manager_secret.fuelix_api_key.secret_id
}

output "github_token_secret_id" {
  description = "Secret Manager secret ID holding the GitHub PAT used to post issue comments"
  value       = google_secret_manager_secret.github_token.secret_id
}

output "trigger_name" {
  description = "Cloud Build trigger name for the issue-triage relay"
  value       = google_cloudbuild_trigger.issue_triage.name
}
