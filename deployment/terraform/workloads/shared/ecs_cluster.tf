locals {
  cluster_name = "services"
}

module "ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = local.cluster_name

  cluster_settings = [
    {
      name  = "containerInsights" 
      value = "enabled"
    }
  ]

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        s3_bucket_name = module.naming_conventions.s3_access_logs_bucket_name
        s3_key_prefix  = "ecs/exec/${local.cluster_name}/"
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 0
        base   = 0
      }
    }
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 100
        base   = 100
      }
    }
  }

  tags = module.tags.result
}
