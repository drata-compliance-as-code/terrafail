

# ---------------------------------------------------------------------
# RDS
# ---------------------------------------------------------------------
resource "aws_db_instance" "sac_db_instance" {
  db_name                   = "sacDatabaseName"
  identifier                = "sac-testing-db-instance"
  allocated_storage         = 10
  instance_class            = "db.t3.micro"
  username                  = "sacRDSInstanceName"
  password                  = "randomPasswordThatFollowstheCharLimit"
  engine                    = "mysql"
  skip_final_snapshot       = true
  final_snapshot_identifier = "DELETE"
  db_subnet_group_name      = aws_db_subnet_group.sac_rds_subnet_group.name
  deletion_protection       = false # SaC Testing - Severity: Moderate - Set deletion_protection to false
  backup_retention_period   = 0     # SaC Testing - Severity: Moderate - Set backup_retention_period to default [0, 7]
  engine_version            = "8.0" # SaC Testing - Severity: High - Set engine to unsupported version
  #enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"] # SaC Testing - Severity: High - Set enabled_cloudwatch_logs_exports to []
  #monitoring_interval = 10 # SaC Testing - Severity: Low - Set monitoring_interval to undefined
  #monitoring_role_arn = aws_iam_role.sac_instance_monitoring_role.arn
  iam_database_authentication_enabled = false # SaC Testing - Severity: High - Set iam_database_authentication_enabled to false
  #kms_key_id = aws_kms_key.sac_kms_key.arn # SaC Testing - Severity: High - Set kms_key_id to false
  multi_az            = true
  publicly_accessible = true  # SaC Testing - Severity: Critical - Set publicly_accessible to true
  storage_encrypted   = false # SaC Testing - Severity: Moderate - Set storage_encrypted to false
  # SaC Testing - Severity: Moderate - Set tags to undefined
  # tags = {
  #   Name   = "rds_cluster"
  # }
}

resource "aws_db_proxy_default_target_group" "sac_proxy_target_group" {
  db_proxy_name = aws_db_proxy.sac_rds_db_proxy.name
}

resource "aws_db_proxy_target" "sac_instance_proxy_target" {
  db_proxy_name          = aws_db_proxy.sac_rds_db_proxy.name
  target_group_name      = aws_db_proxy_default_target_group.sac_proxy_target_group.name
  db_instance_identifier = aws_db_instance.sac_db_instance.id
}

resource "aws_db_option_group" "sac_rds_option_group" {
  name                     = "sac-rds-option-group"
  option_group_description = "Terraform Option Group"
  engine_name              = "mysql"
  major_engine_version     = "8.0"
  # SaC Testing - Severity: Moderate - Set tags to undefined
  # tags = {
  #   Name = "rds_option_group"
  # }
}

resource "aws_db_parameter_group" "sac_rds_parameter_group" {
  name   = "sac-rds-param-group"
  family = "mysql5.6"
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
