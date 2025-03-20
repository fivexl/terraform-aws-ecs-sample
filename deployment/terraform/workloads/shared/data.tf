data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

module "naming_conventions" {
  source  = "fivexl/naming-conventions/aws"
  version = "0.0.1"
}

module "default_kms_key_arn" {
  source  = "fivexl/shared-parameters/aws//modules/default_kms_key_arn/read"
  version = "0.0.6"
}

data "aws_vpc" "this" {
  id = var.vpc_id
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  tags = {
    "Type" = "private"
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  tags = {
    "Type" = "public"
  }
}

data "aws_subnets" "db" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  tags = {
    "Type" = "db"
  }
}

data "aws_route53_zone" "primary_public" {
  provider = aws.dns

  name     = var.dns_zone_name
  private_zone = false
}

data "external" "git_repository" {
  program = ["bash", "-c", "echo { \\\"commit_sha\\\": \\\"$(git rev-parse HEAD)\\\" }"]
}

data "aws_ram_resource_share" "pca" {
  name                  = "ecs-private-ca"
  resource_owner        = "OTHER-ACCOUNTS"
  resource_share_status = "ACTIVE"
}