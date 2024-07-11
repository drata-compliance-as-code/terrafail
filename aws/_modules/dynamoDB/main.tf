

# ---------------------------------------------------------------------
# DynamoDB
# ---------------------------------------------------------------------
resource "aws_dynamodb_table" "TerraFailDynamoDB" {
  name           = "TerraFailDynamoDB"
  billing_mode   = "PROVISIONED"
  hash_key       = "UserId"
  range_key      = "GameTitle"
  read_capacity  = 1
  write_capacity = 1

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
    enabled = false
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
    write_capacity     = 1
    read_capacity      = 1
    projection_type    = "INCLUDE"
    non_key_attributes = ["UserId"]
  }

  server_side_encryption {
    enabled = false
  }
}

# ---------------------------------------------------------------------
# KMS
# ---------------------------------------------------------------------
resource "aws_kms_key" "TerraFailDynamoDB_key" {
  description             = "TerraFailDynamoDB encryption key"
  deletion_window_in_days = 10
  enable_key_rotation     = false
  key_usage               = "ENCRYPT_DECRYPT"
  tags = {
    Name = "kms-key-1"
  }

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Describe the policy statement",
      "Effect": "Allow",
      "Principal": {
          "AWS" : ["${data.aws_caller_identity.current.arn}"]
        },
      "Action" : [
          "kms:Create",
          "kms:Describe",
          "kms:Enable",
          "kms:List",
          "kms:Put",
          "kms:Update",
          "kms:Revoke",
          "kms:Disable",
          "kms:Get",
          "kms:Delete",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion",
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "kms:KeySpec": "SYMMETRIC_DEFAULT"
        }
      }
    }
  ]
}
EOF
}
