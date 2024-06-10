

# ---------------------------------------------------------------------
# WAFv2
# ---------------------------------------------------------------------
resource "aws_wafv2_ip_set" "TerraFailWAF_ip_set" {
  name               = "TerraFailWAF_ip_set"
  description        = "TerraFailWAF_ip_set description"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = ["1.2.3.4/32", "5.6.7.8/32"]
}

resource "aws_wafv2_rule_group" "TerraFailWAF_rule_group" {
  name     = "TerraFailWAF_rule_group"
  scope    = "REGIONAL"
  capacity = 2

  rule {
    name     = "rule-1"
    priority = 1

    action {
      block {}
    }

    statement {
      geo_match_statement {
        country_codes = ["US"]
      }

    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "friendly-metric-name"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "friendly-metric-name"
    sampled_requests_enabled   = false
  }
}


resource "aws_TerraFailWAF_web_acl" "TerraFailWAF_web_acl" {
  name        = "TerraFailWAF_web_acl"
  description = "TerraFailWAF_web_acl managed rule"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "rule-1"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 100000
        aggregate_key_type = "IP"

        scope_down_statement {
          geo_match_statement {
            country_codes = ["US", "NL"]
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "friendly-metric-name"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "friendly-metric-name"
    sampled_requests_enabled   = false
  }
}

resource "aws_wafv2_regex_pattern_set" "TerraFailWAF_regex_pattern_set" {
  # Drata: Set [aws_wafv2_regex_pattern_set.tags] to ensure that organization-wide tagging conventions are followed.
  name        = "TerraFailWAF_regex_pattern_set"
  description = "TerraFailWAF_regex_pattern_set description"
  scope       = "REGIONAL"
}
