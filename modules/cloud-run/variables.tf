variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "environments" {
  description = "List of deployment environments"
  type        = list(string)
}

variable "vpc_connector_id" {
  description = "Serverless VPC connector ID"
  type        = string
}

variable "app_name" {
  description = "Application name prefix for Cloud Run services"
  type        = string
  default     = "hello-world"
}
