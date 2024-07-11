module "ecs_service" {
  for_each = var.services

  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "5.11.3"

  name        = each.key
  cluster_arn = aws_ecs_cluster.ecs_sample.arn

  cpu    = 256
  memory = 512

  # Enables ECS Exec
  enable_execute_command = true

  # Container definition(s)
  container_definitions = {
    (local.app_container_name) = {
      essential = true
      image     = "${aws_ecr_repository.repo[each.key].repository_url}:${each.value.version}"
      port_mappings = [
        {
          name          = local.app_container_name
          containerPort = each.value.port
          hostPort      = each.value.port
          protocol      = "tcp"
        }
      ]
      readonly_root_filesystem  = false # nginx need to write tmp files
      enable_cloudwatch_logging = true
      health_check = {
        command = ["CMD", "lprobe", "-port=${each.value.port}", "-endpoint=${each.value.health_check_path}"]
      }
    }
  }

  service_connect_configuration = {}

  service_registries = {
    registry_arn = aws_service_discovery_service.ecs_sample[each.key].arn
  }

  load_balancer = try(each.value.domain_name, "") != "" ? {
    service = {
      target_group_arn = var.alb_target_group_arn
      container_name   = local.app_container_name
      container_port   = each.value.port
    }
  } : {}

  subnet_ids = var.private_subnets
  security_group_rules = {
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

resource "aws_security_group_rule" "ingress" {
  for_each = toset(
    flatten(
      [
        for service in keys(var.services) :
        [
          for target in var.services[service].ingress_from :
          "${service}:${target}"
        ]
      ]
    )
  )
  type                     = "ingress"
  description              = split(":", each.key)[1]
  from_port                = var.services[split(":", each.key)[0]].port
  to_port                  = var.services[split(":", each.key)[0]].port
  protocol                 = "tcp"
  security_group_id        = module.ecs_service[split(":", each.key)[0]].security_group_id
  source_security_group_id = module.ecs_service[split(":", each.key)[1]].security_group_id
}

resource "aws_security_group_rule" "alb" {
  for_each                 = { for k, v in var.services : k => v if try(v.domain_name, "") != "" }
  type                     = "ingress"
  description              = "alb"
  from_port                = each.value.port
  to_port                  = each.value.port
  protocol                 = "tcp"
  security_group_id        = module.ecs_service[each.key].security_group_id
  source_security_group_id = var.alb_sg_id
}