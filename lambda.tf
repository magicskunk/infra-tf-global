# packing and adding lambda fn to s3
data "archive_file" "lambda_send_email" {
  type = "zip"

  source_file = "${path.module}/src/lambda_send_email.js"
  output_path = "${path.module}/src/dist/lambda_send_email.zip"
}

resource "aws_s3_object" "lambda_send_email" {
  bucket = aws_s3_bucket.infra_global.id

  key    = "lambda_send_email.zip"
  source = data.archive_file.lambda_send_email.output_path

  etag = filemd5(data.archive_file.lambda_send_email.output_path)
}


resource "aws_cloudwatch_log_group" "lambda_send_email" {
  name = "/aws/lambda/${aws_lambda_function.send_email.function_name}"

  retention_in_days = 30
}

# create ln fn
resource "aws_lambda_function" "send_email" {
  function_name = "lambda_send_email"

  s3_bucket = aws_s3_bucket.infra_global.id
  s3_key    = aws_s3_object.lambda_send_email.key

  runtime = "nodejs18.x"
  handler = "lambda_send_email.handler"

  source_code_hash = data.archive_file.lambda_send_email.output_base64sha256

  # role argument of this resource is the function's EXECUTION ROLE for identity and access to AWS services and resources.
  role = aws_iam_role.lambda_exec.arn
}
