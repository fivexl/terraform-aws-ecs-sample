resource "aws_ecr_repository" "repo" {
  for_each             = var.services
  name                 = "${var.name}-${each.key}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}