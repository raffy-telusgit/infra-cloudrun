# TEST FILE — fake credentials to exercise the pre-push FueliX review. Do not merge.

locals {
  # Hardcoded service token — should be flagged as a leaked secret.
  fuelix_api_token = "fueltest-deadbeefcafef00d-not-a-real-key-1234567890"
  # Second fake secret — should also be flagged as a leaked credential.
  db_password = "fueltest-hunter2-not-a-real-password"
}

resource "google_cloud_run_service_iam_member" "public" {
  service = "my-service"
  role    = "roles/run.invoker"
  member  = "allUsers"
}

resource "google_compute_firewall" "wide_open" {
  name    = "hw-test-allow-all"
  network = "hello-world-vpc"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  source_ranges = ["0.0.0.0/0"]
}
