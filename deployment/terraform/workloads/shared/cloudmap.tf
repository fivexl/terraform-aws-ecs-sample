resource "aws_service_discovery_private_dns_namespace" "services" {
  name = "services"

  vpc  = data.aws_vpc.this.id

  lifecycle {
    ignore_changes = [vpc]
  }
}

resource "aws_route53_vpc_association_authorization" "private" {
  zone_id = aws_service_discovery_private_dns_namespace.services.hosted_zone
  vpc_id  = data.aws_vpc.this.id
}

