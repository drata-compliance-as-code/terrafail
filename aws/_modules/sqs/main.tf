
# ---------------------------------------------------------------------
# SQS
# ---------------------------------------------------------------------
resource "aws_sqs_queue" "TerraFailSQS" {
  name                      = "TerraFailSQS"
  kms_master_key_id         = aws_kms_key.TerraFailSQS_key.id
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
}

resource "aws_sqs_queue_policy" "TerraFailSQS_policy" {
  queue_url = aws_sqs_queue.TerraFailSQS.id
  policy    = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "SQS:*",
            "Resource": "*",
            "Principal": {"AWS" : "*"}
        }
    ]
}
EOF
}

# ---------------------------------------------------------------------
# KMS
# ---------------------------------------------------------------------
resource "aws_kms_key" "TerraFailSQS_key" {
  description             = "TerraFailSQS_key"
  deletion_window_in_days = 10
}
