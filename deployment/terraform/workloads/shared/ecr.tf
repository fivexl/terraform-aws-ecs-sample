#tfsec:ignore:AWS078 #tfsec:ignore:AWS093
resource "aws_ecr_repository" "this" {
  for_each = var.create_ecr_resources ? local.services : tomap({})

  name = each.key
  image_scanning_configuration {
    scan_on_push = "true"
  }
  image_tag_mutability = "MUTABLE"
  encryption_configuration {
    encryption_type = "AES256"
  }
  tags = merge(
    module.tags.result,
    {
      "Name" = each.key
    }
  )
}

resource "aws_ecr_lifecycle_policy" "this" {
  for_each = var.create_ecr_resources ? aws_ecr_repository.this : {}

  repository = each.key
  policy = jsonencode(
    {
      "rules" : [
        {
          "rulePriority" : 1,
          "description" : "Expire untagged images older than 30 days",
          "selection" : {
            "tagStatus" : "untagged",
            "countType" : "sinceImagePushed",
            "countUnit" : "days",
            "countNumber" : 31
          },
          "action" : {
            "type" : "expire"
          }
        },
        {
          "rulePriority" : 2,
          "description" : "Expire images if there we are approaching limit",
          "selection" : {
            "tagStatus" : "any",
            "countType" : "imageCountMoreThan",
            "countNumber" : 300
          },
          "action" : {
            "type" : "expire"
          }
        }
      ]
    }
  )
}

resource "aws_ecr_repository_policy" "allow_stage_and_prod" {
  for_each   = length(var.allow_ecr_get_for_account_ids) > 0 ? aws_ecr_repository.this : {}

  repository = each.key
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "CrossAccountPermission",
        Effect = "Allow",
        Action = [
          "ecr:ReplicateImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ],
        Principal = {
          # TODO: share with organization
          AWS = [
            for account_id in var.allow_ecr_get_for_account_ids : "arn:aws:iam::${account_id}:root"
          ]
        },
      }
    ]
  })
}

resource "aws_ecr_registry_policy" "ecr_replication" {
  count  = length(var.allow_ecr_get_for_account_ids) > 0 ? 1 : 0

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "CrossAccountPermission",
        Effect = "Allow",
        Action = [
          "ecr:ReplicateImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ],
        Principal = {
          AWS = [
            for account_id in var.allow_ecr_get_for_account_ids : "arn:aws:iam::${account_id}:root"
          ]
        },
        Resource = "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/*"
      }
    ]
  })
}