resource "google_artifact_registry_repository" "issue_triage_agent" {
  project       = var.project_id
  location      = var.region
  repository_id = "issue-triage-agent"
  format        = "DOCKER"
  description   = "Docker images for issue-triage-agent"
}

resource "google_secret_manager_secret" "fuelix_api_key" {
  project   = var.project_id
  secret_id = "issue-triage-agent-fuelix-api-key"

  replication {
    auto {}
  }
}

resource "google_service_account" "issue_triage_agent" {
  project      = var.project_id
  account_id   = "issue-triage-agent-sa"
  display_name = "Issue Triage Agent Cloud Run Runtime"
}

resource "google_secret_manager_secret_iam_member" "issue_triage_agent_secret_accessor" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.fuelix_api_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.issue_triage_agent.email}"
}

resource "google_cloud_run_v2_service" "issue_triage_agent" {
  project  = var.project_id
  name     = "issue-triage-agent"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.issue_triage_agent.email

    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello:latest"

      ports {
        container_port = 8080
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
      max_instance_count = 2
    }
  }

  lifecycle {
    ignore_changes = [
      template,
    ]
  }
}

resource "google_cloud_run_v2_service_iam_member" "github_actions_invoker" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.issue_triage_agent.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${var.github_actions_sa_email}"
}
