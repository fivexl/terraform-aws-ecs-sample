locals {
  name = "ecs-sample"

  services = {
    web = {
      domain_name       = local.name,
      port              = 80
      health_check_path = "/"
      version           = "0.1"
      ingress_from      = []
    },
    dogs = {
      port              = 80
      health_check_path = "/"
      version           = "0.1"
      ingress_from      = ["web"]
    }
    cats = {
      port              = 80
      health_check_path = "/"
      version           = "0.1"
      ingress_from      = ["web"]
    }
  }
}