variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "github_actions_sa_email" {
  description = "Email of the GitHub Actions service account, granted run.invoker on this service"
  type        = string
}
