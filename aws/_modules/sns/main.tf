# ---------------------------------------------------------------------
# SNS
# ---------------------------------------------------------------------
resource "aws_sns_topic" "sac_sns_topic" {
  name         = "sac-testing-sns"
  display_name = "sac-test-sns"
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

resource "aws_sns_topic_subscription" "sac_sns_topic_subscription" {
  topic_arn = aws_sns_topic.sac_sns_topic.arn
  protocol  = "http"
  endpoint  = "http://devapi.oak9.cloud/console/"
}
