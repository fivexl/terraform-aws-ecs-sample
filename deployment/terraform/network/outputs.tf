output "vpc_id" {
  value = module.vpc.vpc_id
}

output "service_discovery_namespace_arn" {
  value = aws_service_discovery_private_dns_namespace.ecs_sample.arn
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "alb_sg_id" {
  value = module.ingress_alb.security_group_id
}

output "alb_target_group_arn" {
  value = module.alb_ingress_rules.lb_target_group_arns[var.name]
}