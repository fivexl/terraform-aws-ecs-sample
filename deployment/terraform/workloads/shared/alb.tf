locals {
  private_subnets = [data.aws_subnets.private.ids[0], data.aws_subnets.private.ids[1]]
}

module "ingress_alb" {
  source             = "terraform-aws-modules/alb/aws"
  version            = "9.9.0"
  name               = "services"
  internal           = true
  load_balancer_type = "application"
  vpc_id             = data.aws_vpc.this.id
  subnets            = local.private_subnets

  create_security_group = true
  security_group_name   = "alb"
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
      cidr_ipv4   = var.vpc.cidr # TODO: data.aws_vpc.selected.cidr_block
    }
  }

  access_logs = {
    bucket  = module.naming_conventions.s3_access_logs_bucket_name
    enabled = true
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
      certificate_arn = aws_acm_certificate_validation.primary_public.certificate_arn
      # additional_certificate_arns = [aws_acm_certificate.internal.arn]
      ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-Ext2-2021-06"
      action_type     = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Unknown host"
        status_code  = "503"
      }

      rules = {
        for key, value in local.services : key => {
          priority = value.priority
          actions = [{
            type             = "forward"
            target_group_key = key
          }]
          conditions = [{
            host_header = {
              values = [ aws_route53_record.services.name ]
            }
          }]
        }
      }
    }
  }

  target_groups = {
    for key, value in local.services : key => {
      name                 = key
      protocol             = "HTTP"
      port                 = value.port
      target_type          = "ip"
      deregistration_delay = 10
      create_attachment    = false # created by ECS service

      health_check = {
        enabled             = true
        interval            = 120
        path                = value.health_check_path
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 3
        timeout             = 20
        protocol            = "HTTP"
        matcher             = "200-399"
      }
    }
  }
}
