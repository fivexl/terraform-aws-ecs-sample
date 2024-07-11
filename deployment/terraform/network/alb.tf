module "ingress_alb" {
  source             = "terraform-aws-modules/alb/aws"
  version            = "9.9.0"
  name               = var.name
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets

  create_security_group = true
  security_group_ingress_rules = {
    all_http = {
      from_port   = local.alb_http_port
      to_port     = local.alb_http_port
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = local.alb_https_port
      to_port     = local.alb_https_port
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  access_logs = {
    bucket  = data.aws_s3_bucket.access_logs.id
    enabled = false # FIXME: enable when CMK access logs bucket is available
  }

  listeners = {
    http = {
      port        = local.alb_http_port
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = local.alb_https_port
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    https = {
      port            = local.alb_https_port
      protocol        = "HTTPS"
      certificate_arn = aws_acm_certificate.ecs_sample.arn
      ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-Ext2-2021-06"
      action_type     = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Unknown host"
        status_code  = "503"
      }

      rules = {
        (var.name) = {
          priority = 1
          actions = [{
            type             = "forward"
            target_group_key = var.name
          }]

          conditions = [{
            host_header = {
              values = [aws_route53_record.ecs_sample.name]
            }
          }]
        }
      }
    }
  }

  target_groups = {
    (var.name) = {
      protocol             = "HTTP"
      port                 = var.services.frontend.port
      target_type          = "ip"
      deregistration_delay = 10
      create_attachment    = false # created by ECS service

      health_check = {
        enabled             = true
        interval            = 5
        path                = var.services.frontend.health_check_path
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 2
        protocol            = "HTTP"
        matcher             = "200-399"
      }
    }
  }
}

moved {
  from = module.network.module.alb_ingress_rules.aws_lb_target_group.this["ecs-sample"]
  to   = module.network.module.ingress_alb.aws_lb_target_group.this["ecs-sample"]
}

moved {
  from = module.network.module.alb_ingress_rules.aws_lb_listener_rule.this_single_target["ecs-sample.fivexl.dev"]
  to   = module.network.module.ingress_alb.aws_lb_listener_rule.this["https/ecs-sample"]
}