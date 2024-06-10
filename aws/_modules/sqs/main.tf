
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
  # Drata: Explicitly define resources for [aws_sqs_queue_policy.policy] in adherence with the principal of least privilege. Avoid the use of overly permissive allow-all access patterns such as ([*])
  # Drata: Explicitly define principals for [aws_sqs_queue_policy.policy] in adherence with the principal of least privilege. Avoid the use of overly permissive allow-all access patterns such as (*)
  # Drata: Explicitly define actions for [aws_sqs_queue_policy.policy] in adherence with the principal of least privilege. Avoid the use of overly permissive allow-all access patterns such as (SQS:*)
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
  # Drata: Define [aws_kms_key.policy] to restrict access to your resource. Follow the principal of minimum necessary access, ensuring permissions are scoped to trusted entities. Exclude this finding if access to Keys is managed using IAM policies instead of a Key policy
  # Drata: Set [aws_kms_key.tags] to ensure that organization-wide tagging conventions are followed.
  description             = "TerraFailSQS_key"
  deletion_window_in_days = 10
}
