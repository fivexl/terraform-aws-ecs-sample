module "tls_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.41.0"

  create_role = true

  role_name         = "ServiceRoleForECSConnectTLS"
  role_description  = "ECS service role to access Private CA for TLS Service Connect"
  role_requires_mfa = false

  custom_role_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonECSInfrastructureRolePolicyForServiceConnectTransportLayerSecurity"]

  trusted_role_services = ["ecs.amazonaws.com"]
}

module "tls_tester_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.41.0"

  create_role = true

  role_name         = "AmazonSSMManagedInstanceCore"
  role_description  = "Instance profile to allow connection to ec2 via SSM"
  role_requires_mfa = false

  create_instance_profile = true

  custom_role_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]

  trusted_role_services = ["ec2.amazonaws.com"]
}