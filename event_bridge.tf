data "aws_cloudwatch_event_bus" "default_us" {
  provider = "aws.us"
  name     = "default"
}

data "aws_cloudwatch_event_bus" "default" {
  name = "default"
}

resource "aws_cloudwatch_event_rule" "iam_login_profile_created_in_us" {
  provider      = "aws.us"
  name          = "capture_aws_iam_login_profile_created"
  description   = "Capture each AWS Console Profile Creation"
  event_pattern = <<EOF
{
  "source": ["aws.iam"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventSource": ["iam.amazonaws.com"],
    "eventName": ["CreateLoginProfile"]
  }
}
EOF
}

data "aws_iam_policy_document" "allow_put_events" {
  provider = "aws.us"
  statement {
    sid       = ""
    effect    = "Allow"
    resources = [data.aws_cloudwatch_event_bus.default.arn]
    actions   = ["events:PutEvents"]
  }
}

resource "aws_cloudwatch_event_bus_policy" "allow_put_events" {
  provider       = "aws.us"
  policy         = data.aws_iam_policy_document.allow_put_events.json
  event_bus_name = data.aws_cloudwatch_event_bus.default_us.name
}

resource "aws_cloudwatch_event_target" "propagate_to_another_region" {
  rule = aws_cloudwatch_event_rule.iam_login_profile_created_in_us.arn
  arn  = aws_cloudwatch_event_rule.iam_login_profile_created.arn
}

resource "aws_cloudwatch_event_rule" "iam_login_profile_created" {
  name        = "capture_aws_iam_login_profile_created"
  description = "Capture each AWS Console Profile Creation"

  event_pattern = <<EOF
{
  "source": ["aws.iam"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventSource": ["iam.amazonaws.com"],
    "eventName": ["CreateLoginProfile"]
  }
}
EOF
}

# allow event bridge to invoke lambda
resource "aws_lambda_permission" "allow_event_bridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.send_email.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.iam_login_profile_created.arn
}

resource "aws_cloudwatch_event_target" "lambda_send_email" {
  rule = aws_cloudwatch_event_rule.iam_login_profile_created.name
  arn  = aws_lambda_function.send_email.arn
}
