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

variable "pipeline_name" {
  description = "Cloud Deploy pipeline name"
  type        = string
}

variable "app_name" {
  description = "Application name prefix for targets"
  type        = string
  default     = "hello-world"
}
