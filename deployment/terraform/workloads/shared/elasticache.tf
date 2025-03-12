locals {
  elasticache = {
    identifier = "vote"
    port       = 6379
  }
}

module "elasticache" {
  source = "terraform-aws-modules/elasticache/aws"

  replication_group_id     = "vote"
  create_cluster           = false
  create_replication_group = true

  engine         = "valkey"
  engine_version = var.elasticache.engine_version
  node_type      = var.elasticache.node_type

  port = local.elasticache.port
  vpc_id = data.aws_vpc.this.id
  security_group_rules = {
      for key, value in local.services : key => {
        type                          = "ingress"
        from_port                     = local.elasticache.port
        to_port                       = local.elasticache.port
        ip_protocol                   = "tcp"
        description                   = "ECS: ${key} service access to ElastiCache: ${local.elasticache.identifier}"
        referenced_security_group_id  = module.ecs_service[key].security_group_id
      } if try(value.enable_redis_access, false)
  }
  subnet_ids               = local.private_subnets

  apply_immediately = var.elasticache.apply_immediately
  auto_minor_version_upgrade = var.elasticache.auto_minor_version_upgrade

  snapshot_retention_limit = var.elasticache.snapshot_retention_limit
  snapshot_window          = "04:00-05:00"
  maintenance_window       = "Mon:05:00-Mon:06:00"

  tags = module.tags.result
}

resource "aws_ssm_parameter" "elasticache" {
  for_each = {
    "/infrastructure/elasticache/${local.elasticache.identifier}/HOST" = module.elasticache.replication_group_primary_endpoint_address
  }

  name        = each.key
  description = "DB parameter for ${local.elasticache.identifier}"
  type        = "SecureString"
  value       = each.value
  tags        = var.tags
}