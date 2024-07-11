locals {
  name = "ecs-sample"

  services = {
    web = {
      domain_name       = local.name,
      port              = 80
      health_check_path = "/"
    },
    dogs = {
      port              = 80
      health_check_path = "/"
    }
    cats = {
      port              = 80
      health_check_path = "/"
    }
  }
}