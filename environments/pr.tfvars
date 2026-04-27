# Production Environment
# Usage: terraform plan -var-file=environments/pr.tfvars
# Init:  terraform init -backend-config=environments/pr.backend.hcl

project_id     = "raffy-pr-project"
project_number = "PLACEHOLDER_PROJECT_NUMBER"  # TODO: update after project creation
region         = "northamerica-northeast1"
github_owner   = "raffy-telusgit"
tfstate_bucket = "raffy-pr-project-tfstate"

# Overrides
vpc_name      = "hello-world-vpc"
pipeline_name = "hello-world-pipeline"
app_name      = "hello-world"
environments  = ["dev", "staging", "prod"]
