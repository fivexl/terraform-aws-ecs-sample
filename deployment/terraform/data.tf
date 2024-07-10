data "aws_s3_bucket" "access_logs" {
  bucket = var.access_logs_bucket_name
}

