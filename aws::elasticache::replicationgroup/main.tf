

# ---------------------------------------------------------------------
# ElastiCache
# ---------------------------------------------------------------------
resource "aws_elasticache_replication_group" "sac_replication_group_redis" {
  preferred_cache_cluster_azs = ["us-east-2b", "us-east-2c"]
  replication_group_id        = "sac-testing-replication-group-redis"
  description                 = "sac testing replication group"
  node_type                   = "cache.t3.small"
  num_cache_clusters          = 2
  parameter_group_name        = "default.redis7"
  port                        = 6379
  multi_az_enabled            = false # SaC Testing - Severity: Moderate - set multi_az_enabled to false
  automatic_failover_enabled  = true
  #snapshot_retention_limit = 0 # SaC Testing - Severity: Moderate - set snapshot_retention_limit to 0
  at_rest_encryption_enabled = true
  transit_encryption_enabled = false # SaC Testing - Severity: Critical - set transit_encryption_enabled to false
  #kms_key_id = aws_kms_key.replication_group_key.id  # SaC Testing - Severity: Moderate - set kms_key_id to undefined
  #security_group_ids = [aws_security_group.cluster_security_group.id]  # SaC Testing - Severity: Moderate - set security_group_ids to undefined
  # SaC Testing - Severity: Moderate - set tags to undefined
  # tags = {
  #   key = "value"
  # }
}
