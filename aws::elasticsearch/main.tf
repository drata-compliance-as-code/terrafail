
# ---------------------------------------------------------------------
# ElasticSearch
# ---------------------------------------------------------------------
resource "aws_elasticsearch_domain" "sac_elasticsearch_domain" {
  domain_name           = "sac-testing-elasticsearch"
  elasticsearch_version = "7.10"
  advanced_security_options {
    enabled                        = false # SaC Testing - Severity: Moderate - Set enabled to false
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = "master"
      master_user_password = "$uper$ecretP@$$w0rd"
    }
  }
  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }
  cluster_config {
    instance_type          = "c6g.large.elasticsearch"
    zone_awareness_enabled = false # SaC Testing - Severity: High - Set zone_awareness_enabled to false
    dedicated_master_count = 2     # SaC Testing - Severity: Low - Set dedicated_master_count != 3
    instance_count         = 2
  }
  encrypt_at_rest {
    enabled = false # SaC Testing - Severity: Moderate - Set enabled to false
    #kms_key_id = aws_kms_key.elasticsearch_key.id  # SaC Testing - Severity: Moderate - Set kms_key_id to undefined
  }
  domain_endpoint_options {
    enforce_https       = false                        # SaC Testing - Severity: Critical - Set enforce_https to false
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }
  node_to_node_encryption {
    enabled = false # SaC Testing - Severity: High - Set enabled to false
  }
  # SaC Testing - Severity: Moderate - Set tags to undefined
  # tags = {
  #   Domain = "TestDomain"
  # }
}
