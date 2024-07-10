locals {
  name = "ecs-sample"

  services = {
    frontend = {
      domain_name       = local.name,
      port              = 8080
      health_check_path = "/"
    }
  }
}