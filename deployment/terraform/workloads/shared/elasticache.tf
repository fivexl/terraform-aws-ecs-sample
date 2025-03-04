
locals {
  elasticache = {
    identifier = "vote"
    port       = 6379
  }
}

module "elasticache" {
  source = "terraform-aws-modules/elasticache/aws"

  cluster_id               = "vote"
  create_cluster           = true
  create_replication_group = false

  engine_version = "7.1"
  node_type      = "cache.t2.micro" # free tier

  maintenance_window = "Mon:05:00-Mon:06:00"
  apply_immediately  = true

  port = local.elasticache.port
  vpc_id = data.aws_vpc.this.id
  security_group_rules = {
    ingress_vpc = {
      # Default type is `ingress`
      # Default port is based on the default engine port
      description = "VPC traffic"
      cidr_ipv4   = data.aws_vpc.this.cidr_block
    }
  }

  # Subnet Group
#   subnet_group_name        = local.name
#   subnet_group_description = "${title(local.name)} subnet group"
  subnet_ids               = local.private_subnets

  # Parameter Group
#   create_parameter_group      = true
# #   parameter_group_name        = local.name
#   parameter_group_family      = "redis7"
#   parameters = [
#     {
#       name  = "latency-tracking"
#       value = "yes"
#     }
#   ]

  tags = module.tags.result
}

# # create redis user

resource "aws_elasticache_user" "this" {
  user_id       = "vote"
  user_name     = "vote"
  # allow all access
  access_string = "on ~* +@all"
  engine        = "REDIS"

  passwords     = ["password123456789"]
}

resource "aws_elasticache_user_group" "this" {
  user_group_id   = "vote"

  engine        = "REDIS"
  user_ids        = ["default", aws_elasticache_user.this.user_id]
}

resource "aws_ssm_parameter" "elasticache" {
  for_each = {
    "/infrastructure/elasticache/${local.elasticache.identifier}/HOST" = module.elasticache.cluster_cache_nodes[0].address #  jsonencode(module.elasticache.this.cache_nodes[0].address)
  }

  name        = each.key
  description = "DB parameter for ${local.elasticache.identifier}"
  type        = "SecureString"
  value       = each.value
  tags        = var.tags
}