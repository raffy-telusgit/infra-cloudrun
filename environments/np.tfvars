# Non-Production Environment
# Usage: terraform plan -var-file=environments/np.tfvars
# Init:  terraform init -backend-config=environments/np.backend.hcl

project_id     = "raffy-cicd-lab-bf9b4f"
project_number = "722064038316"
region         = "northamerica-northeast1"
github_owner   = "raffy-telusgit"
tfstate_bucket = "raffy-cicd-lab-bf9b4f-tfstate"

# Overrides (defaults are fine for np)
vpc_name      = "hello-world-vpc"
pipeline_name = "hello-world-pipeline"
app_name      = "hello-world"
environments  = ["dev", "staging", "prod"]
