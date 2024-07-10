module "sg" {
  for_each = var.services

  source          = "terraform-aws-modules/security-group/aws"
  version         = "5.1.2"
  name            = "${var.name}-${each.key}"
  use_name_prefix = false
  description     = each.key
  vpc_id          = module.vpc.vpc_id

  ingress_with_source_security_group_id = [try(each.value.domain_name, "") != "" ?
    {
      from_port                = each.value.port
      to_port                  = each.value.port
      protocol                 = "TCP"
      description              = "Allow traffic from ALB to ${each.key}"
      source_security_group_id = module.ingress_alb.security_group_id
    } : {}
  ]

  ingress_with_self = [
    {
      from_port   = each.value.port
      to_port     = each.value.port
      protocol    = "TCP"
      description = "Allow communication within security group"
    }
  ]

  egress_rules = ["all-all"]
}