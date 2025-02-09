# first apply requires:
# 1. terraform apply -target module.network.module.vpc (igv not created...)
# 2. terraform apply -target module.network.aws_acm_certificate.ecs_sample 
# (
# network/route53.tf line 16, in resource "aws_route53_record" "ecs_sample_cert_dv"
# The "for_each" map includes keys derived from resource attributes that cannot be determined until apply
# )
# 3. terraform apply

# module "network" {
#   source = "./network"

#   providers = {
#     aws     = aws,
#     aws.dns = aws.dns
#   }

#   name                    = local.name
#   services                = local.services
#   access_logs_bucket_name = var.access_logs_bucket_name
#   dns_admin_role_arn      = var.dns_admin_role_arn
#   dns_zone_name           = var.dns_zone_name

# }

# module "compute" {
#   source = "./compute"

#   providers = {
#     aws = aws
#   }

#   name                            = local.name
#   services                        = local.services
#   service_discovery_namespace_arn = module.network.service_discovery_namespace_arn
#   service_discovery_namespace_id  = module.network.service_discovery_namespace_id
#   private_subnets                 = module.network.private_subnets
#   alb_sg_id                       = module.network.alb_sg_id
#   alb_target_group_arn            = module.network.alb_target_group_arn
#   tls_tester_security_group_id    = module.network.tls_tester_security_group_id
#   access_logs_bucket_id           = data.aws_s3_bucket.access_logs.id
# }
