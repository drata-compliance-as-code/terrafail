# ---------------------------------------------------------------------
# SNS
# ---------------------------------------------------------------------
resource "aws_sns_topic" "TerraFailSNS" {
  # Drata: Set [aws_sns_topic.tags] to ensure that organization-wide tagging conventions are followed.
  name         = "TerraFailSNS"
  display_name = "TerraFailSNS"
  policy       = <<EOF
  # Drata: Define [aws_sns_topic.policy] to restrict access to your resource. Follow the principal of minimum necessary access, ensuring permissions are scoped to trusted entities
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "SNS:Subscribe",
            "Resource": "*",
            "Principal": "*"
        }
    ]
}
EOF

}

resource "aws_sns_topic_subscription" "TerraFailSNS_subscription" {
  topic_arn = aws_sns_topic.TerraFailSNS.arn
  protocol  = "https"
  endpoint  = "www.thisisthedarkside.com"
}
