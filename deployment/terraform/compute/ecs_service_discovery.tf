resource "aws_service_discovery_service" "ecs_sample" {
  for_each = var.enable_service_connect ? toset([]) : toset(keys(var.services))

  name        = each.key
  description = "ECS Service Discovery for ${each.key} service"
  dns_config {
    namespace_id = var.service_discovery_namespace_id
    dns_records {
      ttl  = 5
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }

  force_destroy = true
}