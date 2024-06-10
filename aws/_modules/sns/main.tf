# ---------------------------------------------------------------------
# SNS
# ---------------------------------------------------------------------
resource "aws_sns_topic" "TerraFailSNS" {
  name         = "TerraFailSNS"
  display_name = "TerraFailSNS"
  policy       = <<EOF
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
