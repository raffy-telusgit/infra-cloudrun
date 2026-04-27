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

variable "vpc_name" {
  description = "VPC network name"
  type        = string
  default     = "hello-world-vpc"
}

variable "environments" {
  description = "List of deployment environments"
  type        = list(string)
  default     = ["dev", "staging", "prod"]
}

variable "pipeline_name" {
  description = "Cloud Deploy pipeline name"
  type        = string
  default     = "hello-world-pipeline"
}

variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
}

variable "app_name" {
  description = "Application name prefix"
  type        = string
  default     = "hello-world"
}

variable "tfstate_bucket" {
  description = "GCS bucket for Terraform state"
  type        = string
}
