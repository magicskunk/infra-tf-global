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
  provider           = aws.us
  name               = "event_bridge_invoke_event_bus"
  assume_role_policy = data.aws_iam_policy_document.event_bus_trust.json
}

resource "aws_iam_policy" "allow_put_events" {
  provider = aws.us
  name     = "allow_put_events"
  policy   = data.aws_iam_policy_document.allow_put_events.json
}

resource "aws_iam_role_policy_attachment" "invoke_event_bus" {
  provider   = aws.us
  policy_arn = aws_iam_policy.allow_put_events.arn
  role       = aws_iam_role.invoke_event_bus.name
}

resource "aws_cloudwatch_event_rule" "iam_login_profile_created_in_us" {
  provider      = aws.us
  name          = "capture_aws_iam_login_profile_created"
  description   = "Capture each AWS Console Profile Creation"
  event_pattern = <<EOF
{
  "source": ["aws.iam", "magicskunk.test"],
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
  rule     = aws_cloudwatch_event_rule.iam_login_profile_created_in_us.name
  arn      = data.aws_cloudwatch_event_bus.default.arn
}

resource "aws_cloudwatch_event_rule" "iam_login_profile_created" {
  name        = "capture_aws_iam_login_profile_created"
  description = "Capture each AWS Console Profile Creation"

  event_pattern = <<EOF
{
  "source": ["aws.iam", "magicskunk.test"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventSource": ["iam.amazonaws.com"],
    "eventName": ["CreateLoginProfile"]
  }
}
EOF
}

# allow the eventbridge to send messages to the sqs queue.
data "aws_iam_policy_document" "allow_event_bridge_to_use_sqs" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = [aws_sqs_queue.common.arn]
    actions   = ["sqs:SendMessage"]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudwatch_event_rule.iam_login_profile_created.arn]
    }

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_sqs_queue_policy" "allow_event_bridge_to_use_sqs" {
  queue_url = aws_sqs_queue.common.id
  policy    = data.aws_iam_policy_document.allow_event_bridge_to_use_sqs.json
}

# publish to sqs
resource "aws_cloudwatch_event_target" "publish_event_to_sqs" {
  rule = aws_cloudwatch_event_rule.iam_login_profile_created.name
  arn  = aws_sqs_queue.common.arn
  #  dead_letter_config {
  #    arn = aws_sqs_queue.dlq.arn
  #  }
}
