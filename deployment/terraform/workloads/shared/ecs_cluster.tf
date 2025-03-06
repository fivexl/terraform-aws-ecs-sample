module "ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "services"

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
        s3_key_prefix  = "ecs/exec/services/"
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        # TODO: add non-spot fargate capacity provider and use it in production
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
