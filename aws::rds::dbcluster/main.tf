

# ---------------------------------------------------------------------
# RDS
# ---------------------------------------------------------------------
resource "aws_rds_cluster" "sac_rds_cluster" {
  # Drata: Configure [aws_rds_cluster.availability_zones] to improve infrastructure availability and resilience
  cluster_identifier        = "sac-testing-rds-cluster"
  database_name             = "sacrdsdatabase"
  engine                    = "postgres"
  master_username           = "sacMasterUsername"
  master_password           = "randomlydecidedpassword41characters"
  final_snapshot_identifier = "DELETE"
  skip_final_snapshot       = true
  deletion_protection       = false
  db_subnet_group_name      = aws_db_subnet_group.sac_rds_subnet_group.name
  backup_retention_period   = 7                         # SaC Testing - Severity: Moderate - Set backup_retention_period to default [0, 7]
  engine_version            = "9.6.postgres.16.2-r2" # SaC Testing - Severity: High - Set engine to unsupported version
  #availability_zones = ["us-east-2c", "us-east-2b"]  # SaC Testing - Severity: High - Set availability_zones to []
  storage_encrypted                   = false # SaC Testing - Severity: Moderate - Set storage_encrypted to false
  iam_database_authentication_enabled = false # SaC Testing - Severity: High - Set iam_database_authentication_enabled to false
  #enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"] # SaC Testing - Severity: High - Set enabled_cloudwatch_logs_exports to []
  #kms_key_id = aws_kms_key.sac_kms_key.arn # SaC Testing - Severity: High - Set kms_key_id to undefined
  # SaC Testing - Severity: Moderate - Set tags to undefined
  # tags = {
  #   Name   = "rds_cluster"
  # }
}

resource "aws_db_option_group" "sac_rds_option_group" {
  name                     = "sac-rds-option-group"
  option_group_description = "Terraform Option Group"
  engine_name              = "postgres"
  major_engine_version     = "9.6"
  # SaC Testing - Severity: Moderate - Set tags to undefined
  # tags = {
  #   Name = "rds_option_group"
  # }
}

resource "aws_db_parameter_group" "sac_rds_parameter_group" {
  name   = "sac-rds-param-group"
  family = "postgres16.1"
  parameter {
    name  = "character_set_server"
    value = "utf8"
  }
  # SaC Testing - Severity: Moderate - Set tags to undefined
  # tags = {
  #   Name = "rds_param_group"
  # }
}

resource "aws_db_proxy" "sac_rds_db_proxy" {
  name           = "sac-rds-db-proxy"
  role_arn       = aws_iam_role.db_proxy_role.arn
  vpc_subnet_ids = [aws_subnet.rds_subnet_1.id, aws_subnet.rds_subnet_2.id]
  engine_family  = "MYSQL"
  debug_logging  = true  # SaC Testing - Severity: Moderate - Set debug_logging to true
  require_tls    = false # SaC Testing - Severity: Moderate - Set require_tls to false
  auth {
    secret_arn = aws_secretsmanager_secret.sac_secrets_manager.arn
    #auth_scheme = "SECRETS"  # SaC Testing - Severity: High - Set auth_scheme != secrets
    iam_auth = "DISABLED" # SaC Testing - Severity: High - Set iam_auth to non-preferred value
  }
  # SaC Testing - Severity: Moderate - Set tags to undefined
  # tags = {
  #   Name = "rds_db_proxy"
  # }
}

resource "aws_db_subnet_group" "sac_rds_subnet_group" {
  name        = "sac-rds-subnet-group"
  description = "Our main group of subnets"
  subnet_ids  = [aws_subnet.rds_subnet_1.id, aws_subnet.rds_subnet_2.id]
  # SaC Testing - Severity: Moderate - Set tags to undefined
  # tags = {
  #   key = "value"
  # }
}
