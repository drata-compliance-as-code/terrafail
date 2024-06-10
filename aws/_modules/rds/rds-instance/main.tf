

# ---------------------------------------------------------------------
# RDS
# ---------------------------------------------------------------------
resource "aws_db_instance" "TerraFailDB_instance" {
  db_name                             = "TerraFailDB_instance"
  identifier                          = "TerraFailDB_instance"
  allocated_storage                   = 10
  instance_class                      = "db.t3.micro"
  username                            = "terrafailusername"
  password                            = "randomPasswordThatFollowstheCharLimit"
  engine                              = "mysql"
  skip_final_snapshot                 = true
  final_snapshot_identifier           = "DELETE"
  db_subnet_group_name                = aws_db_subnet_group.TerraFailDB_subnet_group.name
  deletion_protection                 = false
  engine_version                      = "8.0"
  iam_database_authentication_enabled = false
  multi_az                            = false
  publicly_accessible                 = true
  storage_encrypted                   = false
}

resource "aws_db_proxy_default_target_group" "TerraFailDB_proxy_target_group" {
  db_proxy_name = aws_db_proxy.TerraFailDB_proxy.name
}

resource "aws_db_proxy_target" "TerraFailDB_proxy_target" {
  db_proxy_name          = aws_db_proxy.TerraFailDB_proxy.name
  target_group_name      = aws_db_proxy_default_target_group.TerraFailDB_proxy_target_group.name
  db_instance_identifier = aws_db_instance.TerraFailDB_instance.id
}

resource "aws_db_option_group" "TerraFailDB_option_group" {
  name                     = "TerraFailDB_option_group"
  option_group_description = "Terraform Option Group"
  engine_name              = "mysql"
  major_engine_version     = "8.0"
}

resource "aws_db_parameter_group" "TerraFailDB_parameter_group" {
  name   = "TerraFailDB_parameter_group"
  family = "mysql5.6"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }
}

resource "aws_db_proxy" "TerraFailDB_proxy" {
  name           = "TerraFailDB_proxy"
  role_arn       = aws_iam_role.TerraFailDB_role.arn
  vpc_subnet_ids = [aws_subnet.TerraFailDB_subnet.id, aws_subnet.TerraFailDB_subnet_2.id]
  engine_family  = "MYSQL"
  debug_logging  = true
  require_tls    = false

  auth {
    secret_arn = aws_secretsmanager_secret.TerraFailDB_secret.arn
    iam_auth   = "DISABLED"
  }
}

resource "aws_db_subnet_group" "TerraFailDB_subnet_group" {
  name        = "TerraFailDB_subnet_group"
  description = "Our main group of subnets"
  subnet_ids  = [aws_subnet.TerraFailDB_subnet.id, aws_subnet.TerraFailDB_subnet_2.id]
}

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "aws_vpc" "TerraFailDB_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "TerraFailDB_vpc"
  }
}

resource "aws_internet_gateway" "TerraFailDB_gateway" {
  tags = {
    Name = "TerraFailDB_gateway"
  }
}

resource "aws_internet_gateway_attachment" "TerraFailDB_gateway_attachment" {
  internet_gateway_id = aws_internet_gateway.TerraFailDB_gateway.id
  vpc_id              = aws_vpc.TerraFailDB_vpc.id
}

resource "aws_subnet" "TerraFailDB_subnet" {
  vpc_id            = aws_vpc.TerraFailDB_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-2c"

  tags = {
    Name = "TerraFailDB_subnet"
  }
}

resource "aws_subnet" "TerraFailDB_subnet_2" {
  vpc_id            = aws_vpc.TerraFailDB_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "TerraFailDB_subnet_2"
  }
}

# ---------------------------------------------------------------------
# IAM
# ---------------------------------------------------------------------
resource "aws_iam_role" "TerraFailDB_role" {
  name = "TerraFailDB_role"
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
    key = "TerraFailDB_role"
  }
}

# ---------------------------------------------------------------------
# SecretsManager
# ---------------------------------------------------------------------
resource "aws_secretsmanager_secret" "TerraFailDB_secret" {
  # Drata: Explicitly define principals for [aws_secretsmanager_secret.policy] in adherence with the principal of least privilege. Avoid the use of overly permissive allow-all access patterns such as (*)
  # Drata: Explicitly define actions for [aws_secretsmanager_secret.policy] in adherence with the principal of least privilege. Avoid the use of overly permissive allow-all access patterns such as (*)
  name                    = "TerraFailDB_secret"
  description             = "TerraFailDB_secret description"
  kms_key_id              = aws_kms_key.TerraFailDB_key.id
  recovery_window_in_days = 10

  tags = {
    Env = "dev"
  }
}

resource "aws_secretsmanager_secret_policy" "TerraFailDB_secret_policy" {
  secret_arn = aws_secretsmanager_secret.TerraFailDB_secret.arn

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
resource "aws_kms_key" "TerraFailDB_key" {
  # Drata: Define [aws_kms_key.policy] to restrict access to your resource. Follow the principal of minimum necessary access, ensuring permissions are scoped to trusted entities. Exclude this finding if access to Keys is managed using IAM policies instead of a Key policy
  description             = "TerraFailDB key description"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  key_usage               = "ENCRYPT_DECRYPT"

  tags = {
    Name = "TerraFailDB_key"
  }
}
