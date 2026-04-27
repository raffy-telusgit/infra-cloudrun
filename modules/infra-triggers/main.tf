# Trigger: push to "np" branch → terraform apply with np.tfvars
resource "google_cloudbuild_trigger" "np_apply" {
  project  = var.project_id
  name     = "infra-np-apply"
  location = var.region

  github {
    owner = var.github_owner
    name  = var.github_repo

    push {
      branch = "^np$"
    }
  }

  filename = "cloudbuild-apply.yaml"

  substitutions = {
    _ENV = "np"
  }
}

# Trigger: push to "pr" branch → terraform apply with pr.tfvars
resource "google_cloudbuild_trigger" "pr_apply" {
  project  = var.project_id
  name     = "infra-pr-apply"
  location = var.region

  github {
    owner = var.github_owner
    name  = var.github_repo

    push {
      branch = "^pr$"
    }
  }

  filename = "cloudbuild-apply.yaml"

  substitutions = {
    _ENV = "pr"
  }
}

# Trigger: push to any branch EXCEPT np and pr → terraform plan (np)
resource "google_cloudbuild_trigger" "plan" {
  project  = var.project_id
  name     = "infra-plan"
  location = var.region

  github {
    owner = var.github_owner
    name  = var.github_repo

    push {
      branch       = "^(np|pr)$"
      invert_regex = true
    }
  }

  filename = "cloudbuild-plan.yaml"

  substitutions = {
    _ENV = "np"
  }
}

# Grant Cloud Build SA permissions to run Terraform
resource "google_project_iam_member" "cloudbuild_editor" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${var.project_number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_member" "cloudbuild_iam_admin" {
  project = var.project_id
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = "serviceAccount:${var.project_number}@cloudbuild.gserviceaccount.com"
}
