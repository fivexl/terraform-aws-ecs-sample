module "network" {
  source = "./network"

  providers = {
    aws     = aws,
    aws.dns = aws.dns
  }

  name                    = local.name
  services                = local.services
  access_logs_bucket_name = var.access_logs_bucket_name
  dns_admin_role_arn      = var.dns_admin_role_arn
  dns_zone_name           = var.dns_zone_name

}

module "compute" {
  source = "./compute"

  providers = {
    aws = aws
  }

  name                            = local.name
  services                        = local.services
  service_discovery_namespace_arn = module.network.service_discovery_namespace_arn
  service_discovery_namespace_id  = module.network.service_discovery_namespace_id
  private_subnets                 = module.network.private_subnets
  alb_sg_id                       = module.network.alb_sg_id
  alb_target_group_arn            = module.network.alb_target_group_arn
  tls_tester_security_group_id    = module.network.tls_tester_security_group_id
  access_logs_bucket_id           = data.aws_s3_bucket.access_logs.id
}

moved {
  from = module.vpc
  to   = module.network.module.vpc
}