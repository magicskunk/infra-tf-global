resource "aws_s3_bucket" "infra_global" {
  bucket        = "${var.organization_name}-${var.project_name}"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "infra_global" {
  bucket = aws_s3_bucket.infra_global.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "infra_global" {
  bucket = aws_s3_bucket.infra_global.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
