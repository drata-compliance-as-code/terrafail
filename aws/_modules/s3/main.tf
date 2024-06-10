

# ---------------------------------------------------------------------
# S3
# ---------------------------------------------------------------------
resource "aws_s3_bucket" "TerraFailS3_bucket" {
  force_destroy       = false
  object_lock_enabled = false
}

resource "aws_s3_bucket_acl" "TerraFailS3_bucket_acl" {
  bucket = aws_s3_bucket.TerraFailS3_bucket.id
  acl    = "public-read-write"
}

resource "aws_s3_bucket_cors_configuration" "TerraFailS3_bucket_cors" {
  bucket = aws_s3_bucket.TerraFailS3_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["DELETE"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_ownership_controls" "TerraFailS3_bucket_ownership" {
  bucket = aws_s3_bucket.TerraFailS3_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_policy" "TerraFailS3_bucket_policy" {
  bucket = aws_s3_bucket.TerraFailS3_bucket.id
  policy = <<EOF
  # Drata: Configure [aws_s3_bucket_policy.policy] to ensure secure protocols are being used to encrypt resource traffic
{
"Version": "2012-10-17",
"Id": "PutObjPolicy",
"Statement": [{
  "Sid": "DenyObjectsThatAreNotSSEKMS",
  "Principal": "*",
  "Effect": "Allow",
  "Action": "*",
  "Resource": "${aws_s3_bucket.TerraFailS3_bucket.arn}/*",
  "Condition": {
    "Null": {
      "s3:x-amz-server-side-encryption-aws-kms-key-id": "true"
    }
  }
}]
}
EOF
}


resource "aws_s3_bucket_public_access_block" "TerraFailS3_bucket_access" {
  bucket                  = aws_s3_bucket.TerraFailS3_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "TerraFailS3_bucket_versioning" {
  bucket = aws_s3_bucket.TerraFailS3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
