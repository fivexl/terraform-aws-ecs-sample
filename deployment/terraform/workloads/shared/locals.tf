locals {
  services = {
    result = {
      domain_name       = "directresult"
      port              = 8080
      health_check_path = "/health"
      ingress_from      = ["gateway"]
      priority          = 1

      image_version = var.ecr_image_version != "" ? var.ecr_image_version : data.external.git_repository.result.commit_sha

      secrets = {
        DB_HOST     = aws_ssm_parameter.db["/infrastructure/db/${local.rds.identifier}/DB_HOST"].arn
        DB_NAME     = aws_ssm_parameter.db["/infrastructure/db/${local.rds.identifier}/DB_NAME"].arn
        DB_PASSWORD = "${module.db.db_instance_master_user_secret_arn}:password::"
        DB_USER     = "${module.db.db_instance_master_user_secret_arn}:username::"
      }

      environment = {
        DB_PORT   = 5432

        PGSSLMODE = "require"
        NODE_TLS_REJECT_UNAUTHORIZED = "0"
      }

      tasks_iam_role_statements = []
      enable_db_access          = true
    }
    worker = {
      # domain_name       = "worker"
      port              = 8080
      health_check_path = "/health"
      ingress_from      = []
      priority          = 2

      image_version = var.ecr_image_version != "" ? var.ecr_image_version : data.external.git_repository.result.commit_sha

      secrets = {
        DB_HOST     = aws_ssm_parameter.db["/infrastructure/db/${local.rds.identifier}/DB_HOST"].arn
        DB_NAME     = aws_ssm_parameter.db["/infrastructure/db/${local.rds.identifier}/DB_NAME"].arn
        DB_PASSWORD = "${module.db.db_instance_master_user_secret_arn}:password::"
        DB_USER     = "${module.db.db_instance_master_user_secret_arn}:username::"

        REDIS_HOST  = aws_ssm_parameter.elasticache["/infrastructure/elasticache/${local.elasticache.identifier}/HOST"].arn
      }

      environment = {
        PGSSLMODE = "require"
        DB_PORT   = 5432

        NODE_TLS_REJECT_UNAUTHORIZED = "0"

        # Disable diagnostics
        # Fixes: Failed to create CoreCLR, HRESULT: "0x8007000E" (OOM)
        COMPlus_EnableDiagnostics=0
      }

      tasks_iam_role_statements = []
      enable_db_access          = true
      enable_redis_access       = true
    }
    vote = {
      domain_name       = "directvote"
      port              = 8080
      health_check_path = "/health"
      ingress_from      = ["gateway"]
      priority          = 3

      image_version = var.ecr_image_version != "" ? var.ecr_image_version : data.external.git_repository.result.commit_sha
      secrets = {
        DB_HOST     = aws_ssm_parameter.db["/infrastructure/db/${local.rds.identifier}/DB_HOST"].arn
        DB_NAME     = aws_ssm_parameter.db["/infrastructure/db/${local.rds.identifier}/DB_NAME"].arn
        DB_PASSWORD = "${module.db.db_instance_master_user_secret_arn}:password::"
        DB_USER     = "${module.db.db_instance_master_user_secret_arn}:username::"

        REDIS_HOST  = aws_ssm_parameter.elasticache["/infrastructure/elasticache/${local.elasticache.identifier}/HOST"].arn
      }

      environment = {
        PGSSLMODE = "require"
        DB_PORT   = 5432
      }

      tasks_iam_role_statements = []
      enable_db_access          = true
      enable_redis_access       = true
    }
    gateway = {
      domain_name       = "ecs-demo"
      port              = 8080
      health_check_path = "/health"
      ingress_from      = ["result", "vote"]
      priority          = 4

      image_version = var.ecr_image_version != "" ? var.ecr_image_version : data.external.git_repository.result.commit_sha

      environment = {
        XDG_DATA_HOME = "/tmp"
        DOMAIN = "fivexl.dev"
      }
    }
  }
  alb_http_port  = 80
  alb_https_port = 443
}
