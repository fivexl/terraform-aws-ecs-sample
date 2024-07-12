module "tls_tester" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  name        = "tls_tester"
  description = "Allow VPC traffic mirroring"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 4789
      to_port     = 4789
      protocol    = "udp"
      description = "VXLAN traffic mirroring"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}