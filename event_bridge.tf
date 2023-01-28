data "aws_cloudwatch_event_bus" "default_us" {
  provider = aws.us
  name     = "default"
}

data "aws_cloudwatch_event_bus" "default" {
  name = "default"
}

data "aws_iam_policy_document" "event_bus_trust" {
  provider = aws.us
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "allow_put_events" {
  provider = aws.us
  statement {
    effect    = "Allow"
    resources = [data.aws_cloudwatch_event_bus.default.arn]
    actions   = ["events:PutEvents"]
  }
}

resource "aws_iam_role" "invoke_event_bus" {
  provider = aws.us
  name = "event_bridge_invoke_event_bus"
  assume_role_policy = data.aws_iam_policy_document.event_bus_trust.json
}

resource "aws_iam_policy" "allow_put_events" {
  provider = aws.us
  name = "allow_put_events"
  policy = data.aws_iam_policy_document.allow_put_events.json
}

resource "aws_iam_role_policy_attachment" "invoke_event_bus" {
  provider = aws.us
  policy_arn = aws_iam_policy.allow_put_events.arn
  role       = aws_iam_role.invoke_event_bus.name
}

resource "aws_cloudwatch_event_rule" "iam_login_profile_created_in_us" {
  provider      = aws.us
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

resource "aws_cloudwatch_event_target" "propagate_to_another_region" {
  provider = aws.us
  role_arn = aws_iam_role.invoke_event_bus.arn
  rule = aws_cloudwatch_event_rule.iam_login_profile_created_in_us.name
  arn  = data.aws_cloudwatch_event_bus.default.arn
}

# invoke lambda
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
