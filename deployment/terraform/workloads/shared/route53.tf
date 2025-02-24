resource "aws_route53_record" "services" {
  for_each = { for k, v in local.services : k => v if try(v.domain_name, "") != "" }

  provider = aws.dns

  zone_id  = data.aws_route53_zone.primary_public.zone_id
  name     = "${each.value.domain_name}.${data.aws_route53_zone.primary_public.name}"

  type     = "A"

  alias {
    evaluate_target_health = true
    name                   = module.ingress_alb.dns_name
    zone_id                = module.ingress_alb.zone_id
  }
}
