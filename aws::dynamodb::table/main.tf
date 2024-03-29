

# ---------------------------------------------------------------------
# DynamoDB
# ---------------------------------------------------------------------
resource "aws_dynamodb_table" "dynamo-db-table" {
  name                        = "sactestingtable"
  billing_mode                = "PROVISIONED" # SaC Testing - Severity: Critical - Set billing_mode != 'PAY_PER_REQUEST'
  hash_key                    = "UserId"
  range_key                   = "GameTitle"
  read_capacity               = 1
  write_capacity              = 1
  deletion_protection_enabled = false # SaC Testing - Severity: Moderate - Set deletion_protection_enabled to false
  attribute {
    name = "UserId"
    type = "S"
  }
  attribute {
    name = "GameTitle"
    type = "S"
  }
  attribute {
    name = "TopScore"
    type = "N"
  }
  ttl {
    attribute_name = "TimeToExist"
    enabled        = true
  }
  point_in_time_recovery {
    enabled = false # SaC Testing - Severity: Critical - Set enabled to false
  }
  timeouts {
    create = "10m"
    delete = "10m"
    update = "1h"
  }
  global_secondary_index {
    name               = "GameTitleIndex"
    hash_key           = "GameTitle"
    range_key          = "TopScore"
    write_capacity     = 1 # SaC Testing - Severity: Critical - Set write_capacity < 2
    read_capacity      = 1 # SaC Testing - Severity: Critical - Set read_capacity < 2
    projection_type    = "INCLUDE"
    non_key_attributes = ["UserId"]
  }
  server_side_encryption { # SaC Testing - Severity: Moderate - Set server_side_encryption to undefined
    enabled = false        # SaC Testing - Severity: Critical - Set enabled to false
    #kms_key_arn = "" # SaC Testing - Severity: Critical - Set kms_key_arn to undefined

  }
  # SaC Testing - Severity: Moderate - Set tags to undefined
  # tags = {
  #   Name        = "dynamodb-table-1"
  # }
}
