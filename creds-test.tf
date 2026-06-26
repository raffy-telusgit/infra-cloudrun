# TEST FILE — fake credentials to exercise the pre-push FueliX review. Do not merge.

locals {
  # Hardcoded service token — should be flagged as a leaked secret.
  fuelix_api_token = "fueltest-deadbeefcafef00d-not-a-real-key-1234567890"
}

resource "google_cloud_run_service_iam_member" "public" {
  service = "my-service"
  role    = "roles/run.invoker"
  member  = "allUsers"
}
