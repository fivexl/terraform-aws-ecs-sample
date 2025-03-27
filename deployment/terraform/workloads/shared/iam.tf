module "tls_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.41.0"

  create_role = true

  role_name         = "ServiceRoleForECSConnectTLS"
  role_description  = "ECS service role to access Private CA for TLS Service Connect"
  role_requires_mfa = false

  custom_role_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonECSInfrastructureRolePolicyForServiceConnectTransportLayerSecurity"]

  trusted_role_services = ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]

  tags = module.tags.result
}

resource "aws_iam_policy" "ci_tf" {
  name        = "tf-github-oidc-trust-policy"
  description = "Allow GitHub to assume role"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid": "TemporaryAccessToDeployCI",
        "Effect": "Allow",
        "Action": [
          "ecs:*",
          "iam:*",
          "route53:*",
          "elasticloadbalancing:*",
          "rds:*",
          "ecr:*",
          "s3:*",
          "globalaccelerator:*",
          "ec2:*",
          "acm:*",
          "ram:*",
          "ssm:*",
          "secretsmanager:*",
          "dynamodb:*",
          "logs:*",
          "cloudwatch:*",
          "sts:*",
          "kms:*",
          "application-autoscaling:*"
        ],
        "Resource": "*"
      }
    ]
  })
  tags = module.tags.result
}

module "iam_role_oidc" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.37.2"

  create_role = true

  role_name         = "ci_tf"
  role_description  = "Role that will be used by OIDC & Github to deploy terraform"
  role_requires_mfa = false

  custom_role_policy_arns = [aws_iam_policy.ci_tf.arn]

  create_custom_role_trust_policy = true
  custom_role_trust_policy        = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringLike": {
            "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
            "token.actions.githubusercontent.com:sub": "repo:fivexl/terraform-aws-ecs-sample:*" # TODO:
          }
        }
      },
      {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        },
        "Action": "sts:TagSession"
      },
    ]
  })

  tags = module.tags.result
}
