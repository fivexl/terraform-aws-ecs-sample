locals {
  vpc_cidr       = "10.0.0.0/16"
  azs            = slice(data.aws_availability_zones.available.names, 0, 2)
  alb_http_port  = 80
  alb_https_port = 443
}