output "pipeline_name" {
  description = "Cloud Deploy pipeline name"
  value       = google_clouddeploy_delivery_pipeline.main.name
}

output "dev_target_name" {
  description = "Dev target name"
  value       = google_clouddeploy_target.dev.name
}

output "staging_target_name" {
  description = "Staging target name"
  value       = google_clouddeploy_target.staging.name
}

output "prod_target_name" {
  description = "Prod target name"
  value       = google_clouddeploy_target.prod.name
}
