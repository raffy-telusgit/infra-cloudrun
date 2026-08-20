module "networking" {
  source = "./modules/networking"

  project_id = var.project_id
  region     = var.region
  vpc_name   = var.vpc_name

  providers = {
    google-beta = google-beta
  }
}

module "cloud_run" {
  source = "./modules/cloud-run"

  project_id       = var.project_id
  region           = var.region
  environments     = var.environments
  vpc_connector_id = module.networking.vpc_connector_id
  app_name         = var.app_name
}

module "cloud_deploy" {
  source = "./modules/cloud-deploy"

  project_id     = var.project_id
  project_number = var.project_number
  region         = var.region
  pipeline_name  = var.pipeline_name
  app_name       = var.app_name
}

module "iam" {
  source = "./modules/iam"

  project_id   = var.project_id
  github_owner = var.github_owner
}

module "cloud_build" {
  source = "./modules/cloud-build"

  project_id     = var.project_id
  project_number = var.project_number
  region         = var.region
  github_owner   = var.github_owner
  github_repo    = "${var.app_name}-app"
  app_name       = var.app_name
  pipeline_name  = var.pipeline_name
}

module "infra_triggers" {
  source = "./modules/infra-triggers"

  project_id     = var.project_id
  project_number = var.project_number
  region         = var.region
  github_owner   = var.github_owner
  github_repo    = "infra-cloudrun"
}

module "issue_triage_agent" {
  source = "./modules/issue-triage-agent"

  project_id     = var.project_id
  project_number = var.project_number
  region         = var.region
  github_owner   = var.github_owner
  github_repo    = "${var.app_name}-app"
}
