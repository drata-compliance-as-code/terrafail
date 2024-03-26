# ---------------------------------------------------------------------
# SNS
# ---------------------------------------------------------------------
resource "aws_sns_topic" "sac_sns_topic" {
  name         = "sac-testing-sns"
  display_name = "sac-test-sns"
  #kms_master_key_id =  aws_kms_key.sns_key.id  # SaC Testing - Severity: Low - Set kms_master_key_id to ""

  # SaC Testing - Severity: Critical - Set policy to undefined
  # SaC Testing - Severity: Critical - Set action/resource/principal to *
  #   policy =<<EOF
  # {
  #     "Version": "2012-10-17",
  #     "Statement": [
  #         {
  #             "Effect": "Allow",
  #             "Action": "SNS:Subscribe",
  #             "Resource": "*",
  #             "Principal": "*"
  #         }
  #     ]
  # }
  # EOF

  # SaC Testing - Severity: Moderate - Set tags to undefined
  # tags =  {
  #   tag = "tag1"
  # }
}

resource "aws_sns_topic_policy" "sac_sns_policy" {
  arn = aws_sns_topic.sac_sns_topic.arn
  # SaC Testing - Severity: Critical - Set action/principal to *
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Describe the policy statement",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "sns:Protocol": "https"
        }
      }
    }
  ]
}
EOF
}

resource "aws_sns_topic_subscription" "sac_sns_topic_subscription" {
  topic_arn = aws_sns_topic.sac_sns_topic.arn
  protocol  = "http" # SaC Testing - Severity: Low - Set protocol to non-preferred value
  endpoint  = "http://devapi.oak9.cloud/console/"
}
