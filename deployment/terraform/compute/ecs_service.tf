/*
module "ecs_service" {
    for_each = var.services
  source = "../../modules/service"

  name        = each.key
  cluster_arn = module.ecs_sample.arn

  cpu    = 256
  memory = 512

  # Enables ECS Exec
  enable_execute_command = false

  # Container definition(s)
  container_definitions = {
    (local.app_container_name) = {
      essential = true
      image     = "public.ecr.aws/aws-containers/ecsdemo-frontend:776fd50"
      port_mappings = [
        {
          name          = local.app_container_name
          containerPort = each.port
          hostPort      = each.port
          protocol      = "tcp"
        }
      ]

      enable_cloudwatch_logging = true
      log_configuration = {
        logDriver = "awsfirelens"
        options = {
          Name                    = "firehose"
          region                  = local.region
          delivery_stream         = "my-stream"
          log-driver-buffer-limit = "2097152"
        }
      }
    }
  }

  service_connect_configuration = {}

  load_balancer = {
    service = {
      target_group_arn = var.alb_target_group_arn
      container_name   = local.app_container_name
      container_port   = each.port
    }
  }

  subnet_ids = var.private_subnets
  security_group_rules = {
    alb_ingress = {
      type                     = "ingress"
      from_port                = each.port
      to_port                  = each.port
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = var.alb_sg_id
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}*/