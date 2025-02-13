resource "aws_acm_certificate" "primary_public" {
  domain_name       = "*.${data.aws_route53_zone.primary_public.name}"
  validation_method = "DNS"
}

locals {
  primary_domain_certificate_validation_options = tolist(aws_acm_certificate.primary_public.domain_validation_options)[0]
}

resource "aws_route53_record" "primary_domain_certificate_validation" {
  provider        = aws.dns
  allow_overwrite = true

  ttl     = 60
  name    = local.primary_domain_certificate_validation_options.resource_record_name
  records = [local.primary_domain_certificate_validation_options.resource_record_value]
  type    = local.primary_domain_certificate_validation_options.resource_record_type

  zone_id = data.aws_route53_zone.primary_public.zone_id
}

resource "aws_acm_certificate_validation" "primary_public" {
  certificate_arn         = aws_acm_certificate.primary_public.arn
  validation_record_fqdns = [aws_route53_record.primary_domain_certificate_validation.fqdn]
}
