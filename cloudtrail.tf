resource "aws_cloudtrail" "trail" {
  name                          = "default"
  s3_bucket_name                = aws_s3_bucket.trail.id
  include_global_service_events = true
  is_multi_region_trail         = true
  event_selector {
    exclude_management_event_sources = ["rdsdata.amazonaws.com", "kms.amazonaws.com"]
  }
  depends_on = [aws_s3_bucket_policy.allow_trail_on_s3]
}

resource "aws_s3_bucket" "trail" {
  bucket        = "${var.organization_name}-${var.project_name}-trail"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "trail" {
  bucket = aws_s3_bucket.trail.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "trail" {
  bucket = aws_s3_bucket.trail.id
  acl    = "private"
}

data "aws_iam_policy_document" "allow_trail_on_s3" {
  statement {
    sid       = "AWSCloudTrailAclCheck"
    effect    = "Allow"
    resources = [aws_s3_bucket.trail.arn]
    actions   = ["s3:GetBucketAcl"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }

  statement {
    sid       = "AWSCloudTrailWrite"
    effect    = "Allow"
    resources = ["${aws_s3_bucket.trail.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    actions   = ["s3:PutObject"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

resource "aws_s3_bucket_policy" "allow_trail_on_s3" {
  bucket = aws_s3_bucket.trail.id
  policy = data.aws_iam_policy_document.allow_trail_on_s3.json
}
