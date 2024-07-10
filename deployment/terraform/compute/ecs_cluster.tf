resource "aws_ecs_cluster" "ecs_sample" {

  name = var.name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"
      log_configuration {
        s3_bucket_name = var.access_logs_bucket_id
        s3_key_prefix  = "ecs/exec/${var.name}/"
      }
    }
  }

  service_connect_defaults {
    namespace = var.service_discovery_namespace_arn
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs_sample" {

  cluster_name = aws_ecs_cluster.ecs_sample.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 0
    weight            = 0
    capacity_provider = "FARGATE_SPOT"
  }
}