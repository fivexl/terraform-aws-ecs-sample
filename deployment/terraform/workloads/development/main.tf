provider "aws" {
  region = "us-east-1"
}

module "ou_info" {
  source  = "fivexl/shared-parameters/aws//modules/shared_parameter_data"
  version = "0.0.5"

  resource_share_name = "ou_info"
}

locals {
  ou_info = nonsensitive(jsondecode(module.ou_info.value))
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "workloads" {
  source = "../shared"

  networking_account_id         = tostring(local.ou_info.accounts["tools-network"].id)
  allow_ecr_get_for_account_ids = []
  vpc_id                        = "vpc-0618018ee2bdea049"
  dns_zone_name                 = "fivexl.dev"
  ecr_image_version             = "v0.13"
  create_ecr_resources = true
  vpc = {
    name = "apps"
  }

  db = {
    engine_version                        = "16.3"
    instance_class                        = "db.t4g.micro"
    allocated_storage                     = 20
    auto_minor_version_upgrade            = true
    allow_major_version_upgrade           = false
    apply_immediately                     = true
    backup_retention_period               = 7
    performance_insights_enabled          = true
    performance_insights_retention_period = 7
    enchanced_monitoring_interval         = 60
    multi_az                              = false
    max_allocated_storage                 = 500
  }

  tags = {
    environment_name = "development"
    environment_type = "workloads"
    data_pci         = "0"
    data_phi         = "0"
    data_pii         = "0"
    prefix           = "fivexl"
    data_owner       = "fivexl.com"
  }
  primary_region   = "us-east-1"
  secondary_region = "eu-west-1"
}
