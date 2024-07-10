resource "aws_acm_certificate" "ecs_sample" {
  domain_name       = aws_route53_record.ecs_sample.name
  validation_method = "DNS"
}