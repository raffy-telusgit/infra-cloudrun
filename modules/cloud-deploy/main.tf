resource "google_clouddeploy_delivery_pipeline" "main" {
  project  = var.project_id
  name     = var.pipeline_name
  location = var.region

  description = "Hello World promotion pipeline"

  serial_pipeline {
    stages {
      target_id = google_clouddeploy_target.dev.name
      profiles  = ["dev"]
    }

    stages {
      target_id = google_clouddeploy_target.staging.name
      profiles  = ["staging"]

      strategy {
        canary {
          runtime_config {
            cloud_run {
              automatic_traffic_control = true
            }
          }

          canary_deployment {
            percentages = [25]
            verify      = false
          }
        }
      }
    }

    stages {
      target_id = google_clouddeploy_target.prod.name
      profiles  = ["prod"]

      strategy {
        canary {
          runtime_config {
            cloud_run {
              automatic_traffic_control = true
            }
          }

          canary_deployment {
            percentages = [10, 50]
            verify      = false
          }
        }
      }
    }
  }
}

resource "google_clouddeploy_target" "dev" {
  project  = var.project_id
  name     = "${var.app_name}-dev"
  location = var.region

  run {
    location = "projects/${var.project_id}/locations/${var.region}"
  }

  deploy_parameters = {
    "customTarget/serviceName" = "${var.app_name}-dev"
    "customTarget/environment" = "dev"
  }

  require_approval = false
}

resource "google_clouddeploy_target" "staging" {
  project  = var.project_id
  name     = "${var.app_name}-staging"
  location = var.region

  run {
    location = "projects/${var.project_id}/locations/${var.region}"
  }

  deploy_parameters = {
    "customTarget/serviceName" = "${var.app_name}-staging"
    "customTarget/environment" = "staging"
  }

  require_approval = false
}

resource "google_clouddeploy_target" "prod" {
  project  = var.project_id
  name     = "${var.app_name}-prod"
  location = var.region

  run {
    location = "projects/${var.project_id}/locations/${var.region}"
  }

  deploy_parameters = {
    "customTarget/serviceName" = "${var.app_name}-prod"
    "customTarget/environment" = "prod"
  }

  require_approval = true
}

# Grant Cloud Deploy SA permissions to manage Cloud Run services
resource "google_project_iam_member" "clouddeploy_run_developer" {
  project = var.project_id
  role    = "roles/run.developer"
  member  = "serviceAccount:service-${var.project_number}@gcp-sa-clouddeploy.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "clouddeploy_sa_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:service-${var.project_number}@gcp-sa-clouddeploy.iam.gserviceaccount.com"
}
