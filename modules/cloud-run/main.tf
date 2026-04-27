locals {
  environments = toset(var.environments)
}

resource "google_artifact_registry_repository" "main" {
  project       = var.project_id
  location      = var.region
  repository_id = "${var.app_name}-app"
  format        = "DOCKER"
  description   = "Docker images for ${var.app_name}-app"
}

resource "google_cloud_run_v2_service" "envs" {
  for_each = local.environments

  project  = var.project_id
  name     = "${var.app_name}-${each.key}"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello:latest"

      ports {
        container_port = 8080
      }

      env {
        name  = "ENVIRONMENT"
        value = each.key
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }
    }

    scaling {
      min_instance_count = 0
      max_instance_count = 3
    }

    vpc_access {
      connector = var.vpc_connector_id
      egress    = "ALL_TRAFFIC"
    }

    labels = {
      environment = each.key
    }
  }

  lifecycle {
    ignore_changes = [
      template,
    ]
  }
}
