output "service_account_email" {
  description = "GitHub Actions service account email"
  value       = google_service_account.github_actions.email
}

output "service_account_name" {
  description = "GitHub Actions service account full name"
  value       = google_service_account.github_actions.name
}
