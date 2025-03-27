module "cloudwatch_synthetics_results_bucket" {
  source = "./s3_baseline"
  
  # TODO: use original module when 1.2.4 is released
  # source = "fivexl/account-baseline/aws//modules/s3_baseline"
  # version   = "1.2.3"

  logging = {
    target_bucket = module.naming_conventions.s3_access_logs_bucket_name
  }
  attach_deny_incorrect_encryption_headers = false
  bucket_name = module.naming_conventions.names["cw-synthetics-results"]

  tags = module.tags.result
}

locals {
    cw_syn_vote = {
        name = "vote"
        artifact_s3_name = module.naming_conventions.names["cw-synthetics-results"]
        artifact_s3_path = "canary"
        script_file_path = "../shared/cw-syn-vote.js"
    }
}

data "local_file" "cw_syn_vote" {
  filename = local.cw_syn_vote.script_file_path
}

data "archive_file" "canary_archive_file" {
  type        = "zip"
  output_path = "/tmp/cw-syn-vote-${md5(data.local_file.cw_syn_vote.content)}.zip"

  source {
    content  = data.local_file.cw_syn_vote.content
    filename = "nodejs/node_modules/canary.js"
  }
}

resource "aws_synthetics_canary" "vote" {
  name                 = local.cw_syn_vote.name
  artifact_s3_location = "s3://${local.cw_syn_vote.artifact_s3_name}/${local.cw_syn_vote.artifact_s3_path}"
  execution_role_arn   = module.canary_role.iam_role_arn

  handler              = "canary.handler"
  zip_file             = data.archive_file.canary_archive_file.output_path
  runtime_version      = "syn-nodejs-puppeteer-9.1"
  start_canary         = true
  tags                 = module.tags.result

  schedule {
    expression = "rate(5 minutes)"
  }

run_config {
    active_tracing        = false

    environment_variables = {
      AUTH_USERNAME = jsondecode(data.aws_ssm_parameter.vote_credentials.value).username
      AUTH_PASSWORD = jsondecode(data.aws_ssm_parameter.vote_credentials.value).password
    }
    
    memory_in_mb          = 960
    timeout_in_seconds    = 60
  }
}

data "aws_ssm_parameter" "vote_credentials" {
  name = "/vote/credentials"
}

resource "aws_iam_policy" "canary_policy" {
  name        = "canary-policy"
  description = "Policy for canary"
  policy      = data.aws_iam_policy_document.canary_permissions.json
}

data "aws_iam_policy_document" "canary_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::${local.cw_syn_vote.artifact_s3_name}/${local.cw_syn_vote.artifact_s3_path}/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation"
    ]
    resources = [
      "arn:aws:s3:::${local.cw_syn_vote.artifact_s3_name}"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateLogGroup"
    ]
    resources = [
      "arn:aws:logs:*:*:log-group:/aws/lambda/cwsyn-*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:ListAllMyBuckets",
      "xray:PutTraceSegments"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    resources = [
      "*"
    ]
    actions = [
      "cloudwatch:PutMetricData"
    ]
    condition {
      test     = "StringEquals"
      variable = "cloudwatch:namespace"
      values = [
        "CloudWatchSynthetics"
      ]
    }
  }
}

module "canary_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.54.0"

  role_name = "CloudWatchSyntheticsRole"
  role_description = "Role for CloudWatch Synthetics"

  number_of_custom_role_policy_arns = 1
  custom_role_policy_arns = [aws_iam_policy.canary_policy.arn]
  role_requires_mfa = false
  create_role = true
  trusted_role_services = ["lambda.amazonaws.com"]
}
