module "ecs_service" {
  for_each = local.services

  # TODO: switch to the official module after the PR is merged (TLS support)
  # source  = "terraform-aws-modules/ecs/aws//modules/service"
  # version = "5.11.3"
  source = "github.com/fivexl/terraform-aws-ecs.git//modules/service?ref=3837afb8a6807af418a0819fc4edbf2dbe8ab6e3"

  name        = each.key
  cluster_arn = module.ecs_cluster.cluster_arn

  capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE"
      weight = 100
    },
    {
      capacity_provider = "FARGATE_SPOT"
      weight = 0
    }
  ]

  cpu                      = try(var.ecs_services_config[each.key].cpu, 256)
  memory                   = try(var.ecs_services_config[each.key].memory, 512)
  desired_count            = try(var.ecs_services_config[each.key].desired_count, 1)
  autoscaling_min_capacity = try(var.ecs_services_config[each.key].min_capacity, 1)
  autoscaling_max_capacity = try(var.ecs_services_config[each.key].max_capacity, 1)

  autoscaling_policies = merge(
    {
      cpu = {
        policy_type  = "TargetTrackingScaling"
        target_value = try(var.ecs_services_config[each.key].autoscaling_target, 60)

        target_tracking_scaling_policy_configuration = {
          predefined_metric_specification = {
            predefined_metric_type = "ECSServiceAverageCPUUtilization"
          }
        }
      }
      memory = {
        policy_type  = "TargetTrackingScaling"
        target_value = try(var.ecs_services_config[each.key].autoscaling_target, 60)

        target_tracking_scaling_policy_configuration = {
          predefined_metric_specification = {
            predefined_metric_type = "ECSServiceAverageMemoryUtilization"
          }
        }
      },
    },
    try(each.value.domain_name, "") == "" ? {} :
    {
      requests = {
        policy_type  = "TargetTrackingScaling"
        target_value = try(var.ecs_services_config[each.key].requests_per_target, 1000)

        target_tracking_scaling_policy_configuration = {
          predefined_metric_specification = {
            predefined_metric_type = "ALBRequestCountPerTarget"
            resource_label         = "${module.ingress_alb.arn_suffix}/${module.ingress_alb.target_groups[each.key].arn_suffix}"
          }
        }
      }
  })

  enable_execute_command = true

  container_definitions = {
    "${each.key}" = {
      essential = true
      image = "${(
        var.create_ecr_resources ?
        "${aws_ecr_repository.this[each.key].repository_url}"
        : "${var.ecr_account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${each.key}"
      )}:${each.value.image_version}"

      readonly_root_filesystem = false # Necessary for ECS Exec TODO: remove
      user = "1000:1000"  # Run as non-root user (UID:GID)

      # usefull when you need to apply changes when application is broken
      # wait_for_steady_state     = false
      # wait_until_stable_timeout = "4m"

      port_mappings = [
        {
          name          = "app"
          containerPort = each.value.port
          hostPort      = each.value.port
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]
      enable_cloudwatch_logging = true

      health_check = {
        command     = [ "CMD", "lprobe", "-port=${each.value.port}", "-endpoint=${each.value.health_check_path}"]
        interval    = 15
        timeout     = 5
        retries     = 3
        startPeriod = 30
      }

      environment = concat(
        [
          for key, value in try(each.value.environment, []) : {
            name  = key
            value = value
          }
        ],
        [{
          name  = try(each.value.port_env_var_name, "PORT")
          value = "${each.value.port}"
        }],
        [{
            name  = "PGAPPNAME"
            value = each.key
        }],
        [{
          name  = "IMAGE_VERSION"
          value = "${(
            var.create_ecr_resources ?
            "${aws_ecr_repository.this[each.key].repository_url}"
            : "${var.ecr_account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${each.key}"
          )}:${each.value.image_version}"
        }]
      )
      secrets = [
        for key, value in try(each.value.secrets, []) : {
          name      = key
          valueFrom = value
        }
      ]
    }
  }

  service_connect_configuration = {
    enabled   = true
    namespace = aws_service_discovery_private_dns_namespace.services.arn
    log_configuration = {
      log_driver = "awslogs"
      options = {
        awslogs-region        = data.aws_region.current.name
        awslogs-group         = "/aws/ecs/${each.key}/${each.key}"
        awslogs-stream-prefix = "/ecs-connect"
      }
    }
    service = {
      client_alias = {
        port     = each.value.port
        dns_name = "${each.key}.services"
      }
      port_name      = "app"
      discovery_name = each.key

      tls = {
        role_arn = module.tls_role.iam_role_arn
        issuer_cert_authority = {
          aws_pca_authority_arn = data.aws_ram_resource_share.pca.resource_arns[0]
        }
      }
    }
  }

  task_exec_iam_statements = [
    {
      # Allow ECS to decrypt secrets
      effect = "Allow"
      actions = [
        "kms:Decrypt",
        "kms:DescribeKey",
      ]
      resources = [module.default_kms_key_arn.value]
      sid       = "AllowDecrypt"
    }
  ]

  tasks_iam_role_statements = try(each.value.tasks_iam_role_statements, [])

  load_balancer = try(each.value.domain_name, "") != "" ? {
    service = {
      target_group_arn = module.ingress_alb.target_groups[each.key].arn
      container_name   = each.key
      container_port   = each.value.port
    }
  } : {}

  subnet_ids = local.private_subnets
  security_group_rules = {
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  depends_on = [module.ingress_alb]
}

resource "aws_security_group_rule" "ingress" {
  for_each = toset(
    flatten(
      [
        for service in keys(local.services) :
        [
          for target in local.services[service].ingress_from :
          "${service}:${target}"
        ]
      ]
    )
  )
  type                     = "ingress"
  description              = split(":", each.key)[1]
  from_port                = local.services[split(":", each.key)[0]].port
  to_port                  = local.services[split(":", each.key)[0]].port
  protocol                 = "tcp"
  security_group_id        = module.ecs_service[split(":", each.key)[0]].security_group_id
  source_security_group_id = module.ecs_service[split(":", each.key)[1]].security_group_id
}

resource "aws_security_group_rule" "alb" {
  for_each                 = { for k, v in local.services : k => v if try(v.domain_name, "") != "" }
  type                     = "ingress"
  description              = "alb"
  from_port                = each.value.port
  to_port                  = each.value.port
  protocol                 = "tcp"
  security_group_id        = module.ecs_service[each.key].security_group_id
  source_security_group_id = module.ingress_alb.security_group_id
}

# TODO: make this optional
data "aws_iam_policy" "ssm_managed_instance_core" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  for_each   = module.ecs_service
  role       = each.value.tasks_iam_role_name
  policy_arn = data.aws_iam_policy.ssm_managed_instance_core.arn
}
