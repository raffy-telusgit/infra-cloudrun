variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "project_number" {
  description = "GCP project number"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
}

variable "github_repo" {
  description = "GitHub repo name to watch for issue-triage trigger pushes"
  type        = string
}
