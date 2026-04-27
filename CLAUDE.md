# Infrastructure Repository — Cloud Run + Cloud Deploy

## Project Context
- **GCP Project ID**: raffy-cicd-lab-bf9b4f
- **GCP Project Number**: 722064038316
- **Region**: northamerica-northeast1
- **Terraform state bucket**: raffy-cicd-lab-bf9b4f-tfstate
- **VPC name**: hello-world-vpc

## Environments (3 Cloud Run services)
- dev: hello-world-dev
- staging: hello-world-staging
- prod: hello-world-prod

## Cloud Deploy
- Pipeline name: hello-world-pipeline
- dev: auto-deploy (100%)
- staging: manual promote, 25% canary → 100%
- prod: manual approve, 10% → 50% → 100%

## Conventions
- All Terraform resources use the prefix "hw-" (hello-world)
- Run `terraform fmt` before every commit
- Never hardcode project IDs — always use `var.project_id`
- Cloud Run services connect to VPC via Serverless VPC Connector
- Cloud Deploy manages ALL promotions — GitHub Actions only creates releases
- All secrets go in GitHub Actions secrets, never in .tf files

## CLI Tools
gcloud, terraform, git
