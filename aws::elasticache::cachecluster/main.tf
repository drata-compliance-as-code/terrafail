

# ---------------------------------------------------------------------
# ElastiCache
# ---------------------------------------------------------------------
resource "aws_elasticache_cluster" "sac_memcached_cluster" {
  cluster_id               = "sac-testing-memcached-cluster"
  engine                   = "memcached"
  node_type                = "cache.t3.small"
  num_cache_nodes          = 2
  parameter_group_name     = "default.memcached1.6"
  port                     = 11211 # SaC Testing - Severity: Low - set port to default (11211)
  subnet_group_name        = aws_elasticache_subnet_group.elasticache_subnet_group.name
  snapshot_retention_limit = 0           # SaC Testing - Severity: Moderate - set snapshot_retention_limit = 0
  az_mode                  = "single-az" # SaC Testing - Severity: High - set az_mode != 'cross-az'
  #security_group_ids = [aws_security_group.cluster_security_group.id]  # SaC Testing - Severity: Moderate - set security_group_ids to undefined
  # SaC Testing - Severity: Moderate - set tags to undefined
  # tags = {
  #   resource = "memcached-cluster"
  # }
}