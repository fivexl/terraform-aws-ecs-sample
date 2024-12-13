provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = module.tags.result
  }
}

provider "aws" {
  alias  = "dns"
  region = "us-east-1"
  default_tags {
    tags = module.tags.result
  }
  assume_role {
    role_arn     = var.dns_admin_role_arn
    session_name = "dev-workloads1"
  }
}