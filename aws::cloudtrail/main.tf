
# ---------------------------------------------------------------------
# CloudTrail
# ---------------------------------------------------------------------
resource "aws_cloudtrail" "sac_cloudtrail" {
  name                          = "sac_cloudtrail"
  s3_bucket_name                = aws_s3_bucket.sac_testing.id
  enable_log_file_validation = false    # SaC Testing - Severity: High - Set enable_log_file_validation to false
  is_multi_region_trail = false # SaC Testing - Severity: Moderate - Set is_multi_region_trail to false

#   tags = {  # SaC Testing - Severity: Moderate - Set tags to undefined
#     env: "test"
#   }
}

