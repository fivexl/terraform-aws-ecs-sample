data "aws_ram_resource_share" "pca" {
  name                  = "ecs-private-ca"
  resource_owner        = "OTHER-ACCOUNTS"
  resource_share_status = "ACTIVE"
}

data "aws_region" "current" {}