

# ---------------------------------------------------------------------
# CloudFront
# ---------------------------------------------------------------------
resource "aws_cloudfront_distribution" "sac_cloudfront_distribution" {
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
    target_origin_id       = aws_s3_bucket.sac_cloudfront_log_bucket.id
    viewer_protocol_policy = "allow-all"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  origin {
    origin_id   = aws_s3_bucket.sac_cloudfront_log_bucket.id
    domain_name = aws_s3_bucket.sac_cloudfront_log_bucket.bucket_regional_domain_name

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

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "s3-my-webapp.example.com"
}

# ---------------------------------------------------------------------
# S3
# ---------------------------------------------------------------------
resource "aws_s3_bucket" "sac_cloudfront_log_bucket" {
  bucket = "sac-cloudfront-bucket"
  acl    = "private"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_ownership_controls_sac" {
  bucket = aws_s3_bucket.sac_cloudfront_log_bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_public_access_block_sac" {
  bucket                  = aws_s3_bucket.sac_cloudfront_log_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encrypt" {
  bucket = aws_s3_bucket.sac_cloudfront_log_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.sac_cloudfront_log_bucket.id
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
data "aws_iam_policy_document" "bucket_policy_document" {
  statement {
    actions = ["s3:GetObject"]
    resources = [
      aws_s3_bucket.sac_cloudfront_log_bucket.arn,
      "${aws_s3_bucket.sac_cloudfront_log_bucket.arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }
}

# ---------------------------------------------------------------------
# WAF
# ---------------------------------------------------------------------
resource "aws_wafv2_web_acl" "sac_cloudfront_web_acl_" {
  name        = "sac-testing-web-acl"
  description = "Example of a managed rule."
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
resource "aws_route53_zone" "sac_route_zone" {
  name = "thisisthedarkside.com"
}

resource "aws_route53_record" "websiteurl" {
  name    = "thisisthedarkside.com"
  zone_id = aws_route53_zone.sac_route_zone.id
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.sac_cloudfront_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.sac_cloudfront_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}
