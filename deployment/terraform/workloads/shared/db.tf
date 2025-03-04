locals {
  rds = {
    identifier    = "main"
    kms_key_id    = module.default_kms_key_arn.value
    major_version = split(".", var.db.engine_version)[0]
  }
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.10.0"

  identifier = local.rds.identifier

  engine            = "postgres"
  engine_version    = var.db.engine_version
  instance_class    = var.db.instance_class
  allocated_storage = var.db.allocated_storage

  db_name = local.rds.identifier

  multi_az               = var.db.multi_az
  subnet_ids             = data.aws_subnets.db.ids
  vpc_security_group_ids = [module.database_security_group.security_group_id]

  publicly_accessible = false
  port                = 5432

  storage_encrypted  = true
  storage_type       = "gp3"
  max_allocated_storage = var.db.max_allocated_storage
  ca_cert_identifier = "rds-ca-ecc384-g1"

  username                                               = "postgres"
  iam_database_authentication_enabled                    = true
  manage_master_user_password                            = true
  manage_master_user_password_rotation                   = false # TODO: enable if application supports it
  master_user_password_rotate_immediately                = false
  master_user_password_rotation_automatically_after_days = 30
  master_user_secret_kms_key_id                          = local.rds.kms_key_id
  kms_key_id                                             = local.rds.kms_key_id
  cloudwatch_log_group_kms_key_id                        = local.rds.kms_key_id
  enabled_cloudwatch_logs_exports                        = ["postgresql", "upgrade"]


  auto_minor_version_upgrade            = var.db.auto_minor_version_upgrade
  allow_major_version_upgrade           = var.db.allow_major_version_upgrade
  apply_immediately                     = var.db.apply_immediately
  backup_retention_period               = var.db.backup_retention_period
  performance_insights_enabled          = var.db.performance_insights_enabled
  performance_insights_kms_key_id       = local.rds.kms_key_id
  performance_insights_retention_period = var.db.performance_insights_retention_period
  skip_final_snapshot                   = false
  copy_tags_to_snapshot                 = true
  monitoring_role_name                  = "rds-${local.rds.identifier}-monitoring-role"

  backup_window      = "04:00-05:00"
  maintenance_window = "Mon:05:00-Mon:06:00"

  monitoring_interval    = var.db.enchanced_monitoring_interval
  create_monitoring_role = true
  create_db_subnet_group = true

  create_db_parameter_group = true
  family                    = "postgres${local.rds.major_version}"
  major_engine_version      = local.rds.major_version

  deletion_protection = true

  tags = merge(
    module.tags.result,
    tomap({ "Name" = local.rds.identifier })
  )
}

module "database_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "rds-${local.rds.identifier}"
  description = "Security group for RDS ${local.rds.identifier}"
  vpc_id      = data.aws_vpc.this.id

  ingress_with_source_security_group_id = [
      for key, value in local.services : {
        from_port                = 5432
        to_port                  = 5432
        protocol                 = "tcp"
        description              = "ECS: ${key} service access to RDS: ${local.rds.identifier}"
        source_security_group_id = module.ecs_service[key].security_group_id
      } if try(value.enable_db_access, false)
  ]

  tags = module.tags.result
}

resource "aws_ssm_parameter" "db" {
  for_each = {
    "/infrastructure/db/${local.rds.identifier}/DB_NAME" = module.db.db_instance_name
    "/infrastructure/db/${local.rds.identifier}/DB_HOST" = module.db.db_instance_address
  }

  name        = each.key
  description = "DB parameter for ${local.rds.identifier}"
  type        = "SecureString"
  value       = each.value
  tags        = var.tags
}