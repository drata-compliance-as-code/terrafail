

# ---------------------------------------------------------------------
# RDS
# ---------------------------------------------------------------------
resource "aws_rds_cluster" "TerraFailRDS_cluster" {
  cluster_identifier                  = "TerraFailRDS_cluster"
  database_name                       = "terrafailrdsdb"
  engine                              = "aurora-mysql"
  master_username                     = "terrafailusername"
  master_password                     = "randomlydecidedpassword41characters"
  backup_retention_period             = 1
  final_snapshot_identifier           = "DELETE"
  skip_final_snapshot                 = true
  deletion_protection                 = false
  db_subnet_group_name                = aws_db_subnet_group.TerraFailRDS_subnet_group.name
  engine_version                      = "8.0.mysql_aurora.3.03.0"
  storage_encrypted                   = false
  iam_database_authentication_enabled = false
}

resource "aws_db_option_group" "TerraFailRDS_option_group" {
  name                     = "TerraFailRDS_option_group"
  option_group_description = "Terraform Option Group"
  engine_name              = "mysql"
  major_engine_version     = "8.0"
}

resource "aws_db_parameter_group" "TerraFailRDS_parameter_group" {
  name   = "TerraFailRDS_parameter_group"
  family = "mysql5.6"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }
}

resource "aws_db_proxy" "TerraFailRDS_proxy" {
  name           = "TerraFailRDS_proxy"
  role_arn       = aws_iam_role.TerraFailRDS_role.arn
  vpc_subnet_ids = [aws_subnet.TerraFailRDS_subnet.id, aws_subnet.TerraFailRDS_subnet_2.id]
  engine_family  = "MYSQL"
  debug_logging  = true
  require_tls    = false

  auth {
    secret_arn = aws_secretsmanager_secret.TerraFailRDS_secret.arn
    iam_auth   = "DISABLED"
  }
}

resource "aws_db_subnet_group" "TerraFailRDS_subnet_group" {
  name        = "TerraFailRDS_subnet_group"
  description = "Our main group of subnets"
  subnet_ids  = [aws_subnet.TerraFailRDS_subnet.id, aws_subnet.TerraFailRDS_subnet_2.id]
}

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "aws_vpc" "TerraFailRDS_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "TerraFailRDS_vpc"
  }
}

resource "aws_subnet" "TerraFailRDS_subnet" {
  vpc_id            = aws_vpc.TerraFailRDS_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-2c"

  tags = {
    Name = "TerraFailRDS_subnet"
  }
}

resource "aws_subnet" "TerraFailRDS_subnet_2" {
  vpc_id            = aws_vpc.TerraFailRDS_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "TerraFailRDS_subnet_2"
  }
}

# ---------------------------------------------------------------------
# IAM
# ---------------------------------------------------------------------
resource "aws_iam_role" "TerraFailRDS_role" {
  name = "TerraFailRDS_role"
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
    key = "TerraFailRDS_role"
  }
}

# ---------------------------------------------------------------------
# SecretsManager
# ---------------------------------------------------------------------
resource "aws_secretsmanager_secret" "TerraFailRDS_secret" {
  # Drata: Explicitly define actions for [aws_secretsmanager_secret.policy] in adherence with the principal of least privilege. Avoid the use of overly permissive allow-all access patterns such as (*)
  name                    = "TerraFailRDS_secret"
  description             = "Default config2"
  kms_key_id              = aws_kms_key.TerraFailRDS_key.id
  recovery_window_in_days = 10

  tags = {
    Env = "dev"
  }
}

resource "aws_secretsmanager_secret_policy" "TerraFailRDS_secret_policy" {
  secret_arn = aws_secretsmanager_secret.TerraFailRDS_secret.arn

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
resource "aws_kms_key" "TerraFailRDS_key" {
  # Drata: Define [aws_kms_key.policy] to restrict access to your resource. Follow the principal of minimum necessary access, ensuring permissions are scoped to trusted entities. Exclude this finding if access to Keys is managed using IAM policies instead of a Key policy
  description             = "TerraFailRDS key description"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  key_usage               = "ENCRYPT_DECRYPT"

  tags = {
    Name = "TerraFailRDS_key"
  }
}
