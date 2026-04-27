output "service_urls" {
  description = "Cloud Run service URLs by environment"
  value       = module.cloud_run.service_urls
}

output "registry_url" {
  description = "Artifact Registry URL"
  value       = module.cloud_run.registry_url
}

output "deploy_pipeline_name" {
  description = "Cloud Deploy pipeline name"
  value       = module.cloud_deploy.pipeline_name
}

output "service_account_email" {
  description = "GitHub Actions service account email"
  value       = module.iam.service_account_email
}

output "vpc_connector_id" {
  description = "VPC connector ID"
  value       = module.networking.vpc_connector_id
}
