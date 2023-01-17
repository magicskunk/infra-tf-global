# need another bridge to sync from us to specific region
# or move lambda to us region
resource "aws_cloudwatch_event_rule" "iam_login_profile_created" {
  name        = "capture_aws_iam_login_profile_created"
  description = "Capture each AWS Console Profile Creation"
  depends_on = [aws_lambda_function.send_email]

  # not sure about root props matching of the event, this doesn't work:
  # "source": ["aws.iam"],
  # "detail-type": ["AWS API Call via CloudTrail"],
  event_pattern = <<EOF
{
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
  qualifier     = aws_lambda_alias.send_email.name
  depends_on = [aws_lambda_function.send_email]
}

resource "aws_cloudwatch_event_target" "lambda_send_email" {
  rule = aws_cloudwatch_event_rule.iam_login_profile_created.name
  arn  = aws_lambda_function.send_email.arn
  depends_on = [aws_lambda_function.send_email]
}
