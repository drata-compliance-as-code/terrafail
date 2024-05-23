

# ---------------------------------------------------------------------
# RDS
# ---------------------------------------------------------------------
resource "aws_db_instance" "sac_db_instance" {
  db_name                             = "sacDatabaseName"
  identifier                          = "sac-testing-db-instance"
  allocated_storage                   = 10
  instance_class                      = "db.t3.micro"
  username                            = "sacRDSInstanceName"
  password                            = "randomPasswordThatFollowstheCharLimit"
  engine                              = "mysql"
  skip_final_snapshot                 = true
  final_snapshot_identifier           = "DELETE"
  db_subnet_group_name                = aws_db_subnet_group.sac_rds_subnet_group.name
  deletion_protection                 = false
  engine_version                      = "8.0"
  iam_database_authentication_enabled = false
  multi_az                            = false
  publicly_accessible                 = true
  storage_encrypted                   = false
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
}

resource "aws_db_parameter_group" "sac_rds_parameter_group" {
  name   = "sac-rds-param-group"
  family = "mysql5.6"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }
}

resource "aws_db_proxy" "sac_rds_db_proxy" {
  name           = "sac-rds-db-proxy"
  role_arn       = aws_iam_role.db_proxy_role.arn
  vpc_subnet_ids = [aws_subnet.rds_subnet_1.id, aws_subnet.rds_subnet_2.id]
  engine_family  = "MYSQL"
  debug_logging  = true
  require_tls    = false

  auth {
    secret_arn = aws_secretsmanager_secret.sac_secrets_manager.arn
    iam_auth   = "DISABLED"
  }
}

resource "aws_db_subnet_group" "sac_rds_subnet_group" {
  name        = "sac-rds-subnet-group"
  description = "Our main group of subnets"
  subnet_ids  = [aws_subnet.rds_subnet_1.id, aws_subnet.rds_subnet_2.id]
}

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "aws_vpc" "rds_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "sac-rds-vpc"
  }
}

resource "aws_internet_gateway" "public_rds_gateway" {
  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway_attachment" "public_rds_gateway_attachment" {
  internet_gateway_id = aws_internet_gateway.public_rds_gateway.id
  vpc_id              = aws_vpc.rds_vpc.id
}

resource "aws_subnet" "rds_subnet_1" {
  vpc_id            = aws_vpc.rds_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-2c"

  tags = {
    Name = "Main"
  }
}

resource "aws_subnet" "rds_subnet_2" {
  vpc_id            = aws_vpc.rds_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "Main"
  }
}

# ---------------------------------------------------------------------
# IAM
# ---------------------------------------------------------------------
resource "aws_iam_role" "db_proxy_role" {
  name = "rds_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "rds.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    key = "tag-value"
  }
}

# ---------------------------------------------------------------------
# SecretsManager
# ---------------------------------------------------------------------
resource "aws_secretsmanager_secret" "sac_secrets_manager" {
  name                    = "sac-testing-secrets-manager-02"
  description             = "Default config2"
  kms_key_id              = aws_kms_key.sac_kms_key.id
  recovery_window_in_days = 10

  tags = {
    Env = "dev"
  }
}

resource "aws_secretsmanager_secret_policy" "sac_secrets_manager_policy" {
  secret_arn = aws_secretsmanager_secret.sac_secrets_manager.arn

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EnableAnotherAWSAccountToReadTheSecret",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
POLICY
}

# ---------------------------------------------------------------------
# KMS
# ---------------------------------------------------------------------
resource "aws_kms_key" "sac_kms_key" {
  description             = "This key is used to encrypt dynamoDB objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  key_usage               = "ENCRYPT_DECRYPT"

  tags = {
    Name = "kms-key-1"
  }
}
