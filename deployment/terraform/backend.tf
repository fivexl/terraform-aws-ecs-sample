terraform {
  backend "s3" {
    bucket  = "terraform-state-a6490666acaa9e18f19bdc1559e7c3acde30c9de"
    key     = "terraform/ecs-sample/main.tfstate"
    region  = "eu-central-1"
    encrypt = true
  }
}