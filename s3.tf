resource "aws_s3_bucket" "infra_global" {
  bucket        = "${var.organization_name}-infra-global"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "infra_global" {
  bucket = aws_s3_bucket.infra_global.id
  acl    = "private"
}
