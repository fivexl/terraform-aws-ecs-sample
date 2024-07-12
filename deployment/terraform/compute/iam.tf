module "tls_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.2.0"

  create_role = true

  role_name         = "ServiceRoleForECSConnectTLS"
  role_description  = "ECS service role to access Private CA for TLS Service Connect"
  role_requires_mfa = false

  custom_role_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonECSInfrastructureRolePolicyForServiceConnectTransportLayerSecurity"]

  trusted_role_services = ["ecs.amazonaws.com"]
}