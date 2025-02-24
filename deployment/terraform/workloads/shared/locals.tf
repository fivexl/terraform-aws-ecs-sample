locals {
  services = {
    result = {
      domain_name       = "result"
      port              = 8080
      health_check_path = "/hello"
      ingress_from      = []
      priority          = 1

      image_version = var.ecr_image_version != "" ? var.ecr_image_version : data.external.git_repository.result.commit_sha

      secrets = {
        PG_HOST     = aws_ssm_parameter.db["/infrastructure/db/${local.rds.identifier}/DB_HOST"].arn
        PG_DATABASE = aws_ssm_parameter.db["/infrastructure/db/${local.rds.identifier}/DB_NAME"].arn
        PG_PASSWORD = "${module.db.db_instance_master_user_secret_arn}:password::"
        PG_USER     = "${module.db.db_instance_master_user_secret_arn}:username::"
      }

      environment = {
        PGSSLMODE                    = "require"
      }

      tasks_iam_role_statements = []
      enable_db_access = true
    }
    worker = {
      # domain_name       = "worker"
      port              = 8080
      health_check_path = "/hello"
      ingress_from      = []
      priority          = 2

      image_version = var.ecr_image_version != "" ? var.ecr_image_version : data.external.git_repository.result.commit_sha

      secrets = {
        PG_HOST     = aws_ssm_parameter.db["/infrastructure/db/${local.rds.identifier}/DB_HOST"].arn
        PG_DATABASE = aws_ssm_parameter.db["/infrastructure/db/${local.rds.identifier}/DB_NAME"].arn
        PG_PASSWORD = "${module.db.db_instance_master_user_secret_arn}:password::"
        PG_USER     = "${module.db.db_instance_master_user_secret_arn}:username::"
      }

      environment = {
        PGSSLMODE                    = "require"
      }

      tasks_iam_role_statements = []
      enable_db_access = true
    }
    vote = {
      domain_name       = "vote"
      port              = 8080
      health_check_path = "/hello"
      ingress_from      = []
      priority          = 3

      image_version = var.ecr_image_version != "" ? var.ecr_image_version : data.external.git_repository.result.commit_sha

      secrets = {
        PG_HOST     = aws_ssm_parameter.db["/infrastructure/db/${local.rds.identifier}/DB_HOST"].arn
        PG_DATABASE = aws_ssm_parameter.db["/infrastructure/db/${local.rds.identifier}/DB_NAME"].arn
        PG_PASSWORD = "${module.db.db_instance_master_user_secret_arn}:password::"
        PG_USER     = "${module.db.db_instance_master_user_secret_arn}:username::"
      }

      environment = {
        PGSSLMODE                    = "require"
      }

      tasks_iam_role_statements = []
      enable_db_access = true
    }
  }
  alb_http_port  = 80
  alb_https_port = 443
}
