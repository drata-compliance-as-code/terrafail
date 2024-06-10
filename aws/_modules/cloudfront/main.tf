

# ---------------------------------------------------------------------
# CloudFront
# ---------------------------------------------------------------------
resource "aws_cloudfront_distribution" "TerraFailCloudfront_distribution" {
  enabled = true
  aliases = ["www.thisisthedarkside.com", "thisisthedarkside.com"]

  restrictions {
    geo_restriction {
      locations        = ["AF"]
      restriction_type = "blacklist"
    }
  }

  default_cache_behavior {
    allowed_methods        = ["HEAD", "GET"]
    cached_methods         = ["HEAD", "GET"]
    target_origin_id       = aws_s3_bucket.TerraFailCloudfront_bucket.id
    viewer_protocol_policy = "allow-all"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  origin {
    origin_id   = aws_s3_bucket.TerraFailCloudfront_bucket.id
    domain_name = aws_s3_bucket.TerraFailCloudfront_bucket.bucket_regional_domain_name

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1"]
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:709695003849:certificate/a3919a24-49c7-4607-a690-c203aa2c5b15"
    minimum_protocol_version = "TLSv1"
    ssl_support_method       = "sni-only"
  }
}

resource "aws_cloudfront_TerraFailCloudfront_identity" "TerraFailCloudfront_identity" {
  comment = "s3-my-webapp.example.com"
}

# ---------------------------------------------------------------------
# S3
# ---------------------------------------------------------------------
resource "aws_s3_bucket" "TerraFailCloudfront_bucket" {
  bucket = "TerraFailCloudfront_bucket"
  acl    = "private"

  tags = {
    # Drata: Set [aws_s3_bucket.tags] to ensure that organization-wide tagging conventions are followed.
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_ownership_controls" "TerraFailCloudfront_bucket_ownership" {
  bucket = aws_s3_bucket.TerraFailCloudfront_bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_public_access_block" "TerraFailCloudfront_bucket_access_block" {
  bucket                  = aws_s3_bucket.TerraFailCloudfront_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "TerraFailCloudfront_sse_configuration" {
  bucket = aws_s3_bucket.TerraFailCloudfront_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_website_configuration" "TerraFailCloudfront_website_configuration" {
  bucket = aws_s3_bucket.TerraFailCloudfront_bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

# ---------------------------------------------------------------------
# IAM
# ---------------------------------------------------------------------
data "aws_iam_policy_document" "TerraFailCloudfront_iam_policy" {
  statement {
    actions = ["s3:GetObject"]
    resources = [
      aws_s3_bucket.TerraFailCloudfront_bucket.arn,
      "${aws_s3_bucket.TerraFailCloudfront_bucket.arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_TerraFailCloudfront_identity.TerraFailCloudfront_identity.iam_arn]
    }
  }
}

# ---------------------------------------------------------------------
# WAF
# ---------------------------------------------------------------------
resource "aws_wafv2_web_acl" "TerraFailCloudfront_web_acl" {
  name        = "TerraFailCloudfront_web_acl"
  description = "TerraFailCloudfront_web_acl managed rule."
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "friendly-rule-metric-name"
    sampled_requests_enabled   = false
  }
}

# ---------------------------------------------------------------------
# Route53
# ---------------------------------------------------------------------
resource "aws_route53_zone" "TerraFailCloudfront_route_zone" {
  name = "thisisthedarkside.com"
}

resource "aws_route53_record" "TerraFailCloudfront_route_record" {
  name    = "thisisthedarkside.com"
  zone_id = aws_route53_zone.TerraFailCloudfront_route_zone.id
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.TerraFailCloudfront_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.TerraFailCloudfront_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}
