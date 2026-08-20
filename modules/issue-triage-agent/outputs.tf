output "service_url" {
  description = "URL of the issue-triage-agent Cloud Run service"
  value       = google_cloud_run_v2_service.issue_triage_agent.uri
}

output "service_name" {
  description = "Name of the issue-triage-agent Cloud Run service"
  value       = google_cloud_run_v2_service.issue_triage_agent.name
}

output "secret_id" {
  description = "Secret Manager secret ID holding the FueliX API key"
  value       = google_secret_manager_secret.fuelix_api_key.secret_id
}

output "registry_url" {
  description = "Artifact Registry URL for issue-triage-agent images"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.issue_triage_agent.repository_id}"
}
