

# ---------------------------------------------------------------------
# S3
# ---------------------------------------------------------------------
resource "aws_s3_bucket" "s3_bucket_sac" {
  force_destroy       = false
  object_lock_enabled = false

  # SaC Testing - Severity: Low - Set tags to undefined
  # tags = {
  #   rule      = "all files"
  # }
}

resource "aws_s3_bucket_acl" "s3_bucket_acl-sac" {
  bucket = aws_s3_bucket.s3_bucket_sac.id
  acl    = "public-read-write" # SaC Testing - Severity: Critical/High - Set acl to non-preferred value
}

resource "aws_s3_bucket_cors_configuration" "s3_cors_config_sac" {
  bucket = aws_s3_bucket.s3_bucket_sac.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["DELETE"] # SaC Testing - Severity: High - Set allowed_methods to non-preferred value
    allowed_origins = ["*"]      # SaC Testing - Severity: High - Set allowed_origins to * 
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_ownership_controls_sac" {
  bucket = aws_s3_bucket.s3_bucket_sac.id
  rule {
    object_ownership = "BucketOwnerPreferred" # SaC Testing - Severity: Moderate - Set object_ownership != BucketOwnerEnforced
  }
}

resource "aws_s3_bucket_policy" "s3_bucket_policy_sac" { # SaC Testing - Severity: Critical - Set aws_s3_bucket_policy to undefined
  bucket = aws_s3_bucket.s3_bucket_sac.id
  # SaC Testing - Severity: Critical - Set action/principal to *
  # SaC Testing - Severity: Critical - Set effect to "allow"
  policy = <<EOF
{
"Version": "2012-10-17",
"Id": "PutObjPolicy",
"Statement": [{
  "Sid": "DenyObjectsThatAreNotSSEKMS",
  "Principal": {"AWS" : "${aws_iam_role.s3_bucket_role.arn}"},
  "Effect": "Deny",
  "Action": "s3:PutObject",
  "Resource": "${aws_s3_bucket.s3_bucket_sac.arn}/*",
  "Condition": {
    "Null": {
      "s3:x-amz-server-side-encryption-aws-kms-key-id": "true"
    }
  }
}]
}
EOF
}

resource "aws_s3_bucket_public_access_block" "s3_public_access_block_sac" { # SaC Testing - Severity: Critical - Set aws_s3_bucket_public_access_block to undefined
  bucket                  = aws_s3_bucket.s3_bucket_sac.id
  block_public_acls       = false # SaC Testing - Severity: Critical - Set block_public_acls to false
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "s3_bucket_versioning_sac" { #SaC Testing - Severity: High - Set aws_bucket_versioning to undefined
  bucket = aws_s3_bucket.s3_bucket_sac.id
  versioning_configuration {
    status = "Disabled" # SaC Testing - Severity: High - Set status to false
  }
}

resource "aws_s3_bucket_logging" "s3_bucket_logging" {  #SaC Testing - Severity: High - Set aws_bucket_versioning to undefined
  bucket = aws_s3_bucket.s3_bucket_sac.id
  target_bucket = aws_s3_bucket.s3_bucket_sac.id
  target_prefix = "sac-logs/"
}