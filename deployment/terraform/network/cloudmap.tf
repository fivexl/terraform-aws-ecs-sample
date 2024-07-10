resource "aws_service_discovery_private_dns_namespace" "ecs_sample" {
  name = var.name
  vpc  = module.vpc.vpc_id
}