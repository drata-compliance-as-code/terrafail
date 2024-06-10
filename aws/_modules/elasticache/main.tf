

# ---------------------------------------------------------------------
# ElastiCache
# ---------------------------------------------------------------------
resource "aws_elasticache_cluster" "TerraFailElasticache_cluster_mem" {
  # Drata: Default network security groups allow broader access than required. Specify [aws_elasticache_cluster.security_group_ids] to configure more granular access control
  cluster_id           = "TerraFailElasticache_cluster_mem"
  engine               = "memcached"
  node_type            = "cache.t3.small"
  num_cache_nodes      = 2
  parameter_group_name = "default.memcached1.6"
  port                 = 11211
  subnet_group_name    = aws_TerraFailTerraFailElasticache_subnet_group.TerraFailTerraFailElasticache_subnet_group.name
  az_mode              = "cross-az"
}

resource "aws_elasticache_cluster" "TerraFailElasticache_cluster_red" {
  # Drata: Specify [aws_elasticache_cluster.snapshot_retention_limit] to ensure sensitive data is only available when necessary. Setting snapshot retention to 0 will disable automatic backups
  # Drata: Set [aws_elasticache_cluster.tags] to ensure that organization-wide tagging conventions are followed.
  # Drata: Default network security groups allow broader access than required. Specify [aws_elasticache_cluster.security_group_ids] to configure more granular access control
  cluster_id           = "TerraFailElasticache_cluster_red"
  engine               = "redis"
  node_type            = "cache.t3.small"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  engine_version       = "3.2.10"
  port                 = 6379
  subnet_group_name    = aws_TerraFailTerraFailElasticache_subnet_group.TerraFailTerraFailElasticache_subnet_group.name
}

resource "aws_elasticache_replication_group" "TerraFailElasticache_replication_group" {
  # Drata: Specify [aws_elasticache_replication_group.snapshot_retention_limit] to ensure sensitive data is only available when necessary. Setting snapshot retention to 0 will disable automatic backups
  # Drata: Set [aws_elasticache_replication_group.tags] to ensure that organization-wide tagging conventions are followed.
  # Drata: Default network security groups allow broader access than required. Specify [aws_elasticache_replication_group.security_group_ids] to configure more granular access control
  preferred_cache_cluster_azs = ["us-east-2b", "us-east-2c"]
  replication_group_id        = "TerraFailElasticache_replication_group"
  description                 = "TerraFailElasticache_replication_group description"
  node_type                   = "cache.t3.small"
  num_cache_clusters          = 2
  parameter_group_name        = "default.redis7"
  port                        = 6379
  multi_az_enabled            = true
  automatic_failover_enabled  = true
  at_rest_encryption_enabled  = true
  transit_encryption_enabled  = true
}

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "aws_vpc" "TerraFailElasticache_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "TerraFailElasticache_vpc"
  }
}

resource "aws_TerraFailElasticache_subnet_group" "TerraFailTerraFailElasticache_subnet_group" {
  name       = "TerraFailTerraFailElasticache_subnet_group"
  subnet_ids = [aws_subnet.TerraFailElasticache_subnet.id, aws_subnet.TerraFailElasticache_subnet_2.id]
}

resource "aws_subnet" "TerraFailElasticache_subnet" {
  vpc_id            = aws_vpc.TerraFailElasticache_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "TerraFailElasticache_subnet"
  }
}

resource "aws_subnet" "TerraFailElasticache_subnet_2" {
  vpc_id            = aws_vpc.TerraFailElasticache_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-2c"

  map_public_ip_on_launch = false
  tags = {
    Name = "TerraFailElasticache_subnet_2"
  }
}
