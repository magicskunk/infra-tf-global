# packing and adding lambda fn to s3
# todo lambda from ecr https://hands-on.cloud/terraform-docker-lambda-example/
data "archive_file" "lambda_send_email" {
  type = "zip"

  source_dir  = "${path.module}/lambda/src"
  output_path = "${path.module}/lambda/dist/lambda_send_email.zip"
}

resource "aws_s3_object" "lambda_send_email" {
  bucket = aws_s3_bucket.infra_global.id

  key    = "lambda_send_email.zip"
  source = data.archive_file.lambda_send_email.output_path

  etag = filemd5(data.archive_file.lambda_send_email.output_path)
}


resource "aws_cloudwatch_log_group" "lambda_send_email" {
  name              = "/aws/lambda/${aws_lambda_function.send_email.function_name}"
  retention_in_days = 7
}

# create ln fn
resource "aws_lambda_function" "send_email" {
  function_name = "lambda_send_email"

  s3_bucket = aws_s3_bucket.infra_global.id
  s3_key    = aws_s3_object.lambda_send_email.key

  runtime = "nodejs18.x"
  handler = "lambda_send_email.run"

  source_code_hash = data.archive_file.lambda_send_email.output_base64sha256

  # role argument of this resource is the function's EXECUTION ROLE for identity and access to AWS services and resources.
  role = aws_iam_role.lambda_exec.arn
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid       = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

#allows lambda to consume from sqs
data "aws_iam_policy_document" "allow_lambda_sqs_invocation" {
  statement {
    effect    = "Allow"
    resources = [aws_sqs_queue.common.arn]

    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
    ]
  }
}

data "aws_iam_policy" "allow_lambda_exec" {
  name = "AWSLambdaBasicExecutionRole"
}

#allows lambda to put log events to cloudwatch
resource "aws_iam_policy" "allow_lambda_sqs_invocation" {
  policy = data.aws_iam_policy_document.allow_lambda_sqs_invocation.json
}

# allow lambda to reset pwd, fetch user tags and send email
resource "aws_iam_policy" "send_email" {
  name   = "send_email"
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action   = ["iam:ListUserTags", "iam:UpdateLoginProfile", "ses:SendEmail", "ses:SendRawEmail"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "allow_lambda_exec" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = data.aws_iam_policy.allow_lambda_exec.arn
}

resource "aws_iam_role_policy_attachment" "allow_lambda_sqs_invocation" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.allow_lambda_sqs_invocation.arn
}

resource "aws_iam_role_policy_attachment" "allow_lambda_email_sending" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.send_email.arn
}

resource "aws_lambda_event_source_mapping" "consumer" {
  enabled          = true
  batch_size       = 1
  event_source_arn = aws_sqs_queue.common.arn
  function_name    = aws_lambda_function.send_email.function_name
  depends_on       = [aws_sqs_queue.common]

  #  filter_criteria {
  #    filter {
  #      pattern = jsonencode({
  #        body = {
  #          source : ["aws.iam", "magicskunk.test"],
  #        }
  #      })
  #    }
  #  }
}
