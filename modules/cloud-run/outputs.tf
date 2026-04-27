output "service_urls" {
  description = "Map of environment to Cloud Run service URL"
  value       = { for env, svc in google_cloud_run_v2_service.envs : env => svc.uri }
}

output "service_names" {
  description = "Map of environment to Cloud Run service name"
  value       = { for env, svc in google_cloud_run_v2_service.envs : env => svc.name }
}

output "registry_url" {
  description = "Artifact Registry URL"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.main.repository_id}"
}
