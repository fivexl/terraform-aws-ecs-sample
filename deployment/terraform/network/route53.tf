resource "aws_route53_record" "ecs_sample" {
  provider = aws.dns
  zone_id  = data.aws_route53_zone.primary.zone_id
  name     = "${var.services.frontend.domain_name}.${data.aws_route53_zone.primary.name}"
  type     = "A"
  alias {
    evaluate_target_health = true
    name                   = module.ingress_alb.dns_name
    zone_id                = module.ingress_alb.zone_id
  }
}

resource "aws_route53_record" "ecs_sample_cert_dv" {
  provider = aws.dns

  for_each = {
    for dvo in try(aws_acm_certificate.ecs_sample.domain_validation_options, {}) : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.primary.zone_id
}