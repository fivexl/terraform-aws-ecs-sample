data "aws_availability_zones" "available" {
  filter {
    name   = "state"
    values = ["available"]
  }
  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

data "aws_route53_zone" "primary" {
  provider = aws.dns
  name     = var.dns_zone_name
}

data "aws_s3_bucket" "access_logs" {
  bucket = var.access_logs_bucket_name
}