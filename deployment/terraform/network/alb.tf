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
    }
  }
}

module "alb_ingress_rules" {

  source  = "fivexl/alb-ingress-rules/aws"
  version = "1.0.0"

  lb_listener_arn = module.ingress_alb.listeners["https"].arn

  domain_names      = [aws_route53_record.ecs_sample.fqdn]
  ingress_port      = var.services.frontend.port
  protocol          = "HTTP"
  health_check_path = var.services.frontend.health_check_path

  target_groups_map = {
    "${var.name}" = 100
  }

  vpc_id = module.vpc.vpc_id
}