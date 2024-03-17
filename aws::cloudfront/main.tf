

# ---------------------------------------------------------------------
# CloudFront
# ---------------------------------------------------------------------
resource "aws_cloudfront_distribution" "sac_cloudfront_distribution" {
  enabled = true
  aliases = ["www.thisisthedarkside.com", "thisisthedarkside.com"]
  #web_acl_id = aws_wafv2_web_acl.sac_cloudfront_web_acl_.id  # SaC Testing - Severity: High - set web_acl_id to undefined
  #default_root_object = "index.html" # SaC Testing - Severity: Moderate - set default_root_object to undefined
  restrictions {
    geo_restriction {
      locations        = ["AF"]
      restriction_type = "blacklist"
    }
  }
  logging_config { # SaC Testing - Severity: High - set logging_config to undefined
    bucket = "sac-cloudfront-bucket.s3.amazonaws.com"
  }
  origin_group { # SaC Testing - Severity: Moderate - set origin_group to undefined
    origin_id = "FailoverGroup"

    failover_criteria {
      status_codes = [403, 404, 500, 502]
    }
    member {
      origin_id = "failoverS3"
    }
  }
  default_cache_behavior {
    allowed_methods        = ["HEAD", "GET"]
    cached_methods         = ["HEAD", "GET"]
    target_origin_id       = aws_s3_bucket.sac_cloudfront_log_bucket.id
    viewer_protocol_policy = "allow-all" # SaC Testing - Severity: High - set viewer_protocol_policy = 'allow-all'
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
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1"] # SaC Testing - Severity: High - set origin_ssl_protocols to non-preferred values
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "arn:aws:acm:us-east-2:709695003849:certificate/2c0bef53-a821-4722-939e-d3c29a2dd3b3"
    minimum_protocol_version = "TLSv1" # SaC Testing - Severity: Moderate - set minimum_protocol_version to non-preferred value
    ssl_support_method       = "sni-only"
  }
  # SaC Testing - Severity: Moderate - set tags to undefined
  # tags = {
  #   key = "value"
  # }
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "s3-my-webapp.example.com"
}
