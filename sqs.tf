# sqs is long polling
# message retention is up to 14 days
# docs https://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_SetQueueAttributes.html
resource "aws_sqs_queue" "common" {
  name                      = "${var.organization_name}-${var.project_name}"
  delay_seconds             = 30
  max_message_size          = 2048
  message_retention_seconds = 604800
  receive_wait_time_seconds = 10 # long-poll freq
  redrive_policy            = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 4 # retry count
  })
}

resource "aws_sqs_queue" "dlq" {
  name                 = "${var.organization_name}-${var.project_name}-dlq"
  redrive_allow_policy = jsonencode({
    redrivePermission = "allowAll"
  })
}
