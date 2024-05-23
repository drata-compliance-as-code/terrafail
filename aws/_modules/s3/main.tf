

# ---------------------------------------------------------------------
# S3
# ---------------------------------------------------------------------
resource "aws_s3_bucket" "s3_bucket_sac" {
  force_destroy       = false
  object_lock_enabled = false
}

resource "aws_s3_bucket_acl" "s3_bucket_acl-sac" {
  bucket = aws_s3_bucket.s3_bucket_sac.id
  acl    = "public-read-write"
}

resource "aws_s3_bucket_cors_configuration" "s3_cors_config_sac" {
  bucket = aws_s3_bucket.s3_bucket_sac.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["DELETE"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_ownership_controls_sac" {
  bucket = aws_s3_bucket.s3_bucket_sac.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_policy" "s3_bucket_policy_sac" {
  bucket = aws_s3_bucket.s3_bucket_sac.id
  policy = <<EOF
{
"Version": "2012-10-17",
"Id": "PutObjPolicy",
"Statement": [{
  "Sid": "DenyObjectsThatAreNotSSEKMS",
  "Principal": "*",
  "Effect": "Allow",
  "Action": "*",
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


resource "aws_s3_bucket_public_access_block" "s3_public_access_block_sac" {
  bucket                  = aws_s3_bucket.s3_bucket_sac.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_versioning" "s3_bucket_versioning_sac" {
  bucket = aws_s3_bucket.s3_bucket_sac.id
  versioning_configuration {
    status = "Disabled"
  }
}
