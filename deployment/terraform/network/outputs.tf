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
  value = module.ingress_alb.target_groups[var.name].arn
}

output "service_discovery_namespace_id" {
  value = aws_service_discovery_private_dns_namespace.ecs_sample.id
}

output "tls_tester_security_group_id" {
  value = module.tls_tester.security_group_id
}