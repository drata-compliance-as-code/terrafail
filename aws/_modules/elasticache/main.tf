

# ---------------------------------------------------------------------
# ElastiCache
# ---------------------------------------------------------------------
resource "aws_elasticache_cluster" "TerraFailElasticache_cluster_mem" {
  cluster_id           = "TerraFailElasticache_cluster_mem"
  engine               = "memcached"
  node_type            = "cache.t3.small"
  num_cache_nodes      = 2
  parameter_group_name = "default.memcached1.6"
  port                 = 11211
  subnet_group_name    = aws_TerraFailTerraFailElasticache_subnet_group.TerraFailTerraFailElasticache_subnet_group.name
  az_mode              = "single-az"
}

resource "aws_elasticache_cluster" "TerraFailElasticache_cluster_red" {
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
  preferred_cache_cluster_azs = ["us-east-2b", "us-east-2c"]
  replication_group_id        = "TerraFailElasticache_replication_group"
  description                 = "TerraFailElasticache_replication_group description"
  node_type                   = "cache.t3.small"
  num_cache_clusters          = 2
  parameter_group_name        = "default.redis7"
  port                        = 6379
  multi_az_enabled            = false
  automatic_failover_enabled  = true
  at_rest_encryption_enabled  = false
  transit_encryption_enabled  = false
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
