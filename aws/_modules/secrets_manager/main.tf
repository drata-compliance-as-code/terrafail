

# ---------------------------------------------------------------------
# SecretsManager
# ---------------------------------------------------------------------
resource "aws_secretsmanager_secret_rotation" "TerraFailSecretsManager_rotation" {
  secret_id           = aws_secretsmanager_secret.TerraFailSecretsManager_secret.id
  rotation_lambda_arn = aws_lambda_function.TerraFailSecretsManager_lambda.arn

  rotation_rules {
    automatically_after_days = 90
  }
}

resource "aws_secretsmanager_secret" "TerraFailSecretsManager_secret" {
  name                    = "TerraFailSecretsManager_secret"
  description             = "TerraFailSecretsManager_secret description"
  recovery_window_in_days = 10
}

resource "aws_secretsmanager_secret_policy" "TerraFailSecretsManager_policy" {
  secret_arn = aws_secretsmanager_secret.TerraFailSecretsManager_secret.arn

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
# Lambda
# ---------------------------------------------------------------------
resource "aws_lambda_function" "TerraFailSecretsManager_lambda" {
  function_name                  = "TerraFailSecretsManager_lambda"
  role                           = aws_iam_role.TerraFailSecretsManager_role.arn
  filename                       = "my-deployment-package.zip"
  handler                        = "index.handler"
  runtime                        = "dotnet6"
  reserved_concurrent_executions = 2
  kms_key_arn                    = aws_kms_key.TerraFailSecretsManager_key.arn

  tags = {
    Name = "TerraFailSecretsManager_lambda"
  }

  vpc_config {
    subnet_ids         = [aws_subnet.TerraFailSecretsManager_subnet.id]
    security_group_ids = [aws_security_group.TerraFailSecretsManager_security_group.id]
  }

  dead_letter_config {
    target_arn = aws_sns_topic.TerraFailSecretsManager_topic.arn
  }
}

resource "aws_lambda_permission" "TerraFailSecretsManager_permission" {
  function_name = aws_lambda_function.TerraFailSecretsManager_lambda.function_name
  statement_id  = "AllowExecutionSecretManager"
  action        = "lambda:InvokeFunction"
  principal     = "secretsmanager.amazonaws.com"
}

# ---------------------------------------------------------------------
# SNS
# ---------------------------------------------------------------------
resource "aws_sns_topic" "TerraFailSecretsManager_topic" {
  name = "TerraFailSecretsManager_topic"
}

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "aws_security_group" "TerraFailSecretsManager_security_group" {
  vpc_id = aws_vpc.TerraFailSecretsManager_vpc.id
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_subnet" "TerraFailSecretsManager_subnet" {
  vpc_id     = aws_vpc.TerraFailSecretsManager_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "TerraFailSecretsManager_vpc"
  }
}

resource "aws_vpc" "TerraFailSecretsManager_vpc" {
  cidr_block = "10.0.0.0/16"
}


# ---------------------------------------------------------------------
# IAM
# ---------------------------------------------------------------------
resource "aws_iam_role" "TerraFailSecretsManager_role" {
  name               = "TerraFailSecretsManager_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",

      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "TerraFailSecretsManager_iam_policy" {
  name = "TerraFailSecretsManager_iam_policy"
  role = aws_iam_role.TerraFailSecretsManager_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue",
          "secretsmanager:UpdateSecretVersionStage",
          "sns:Publish"

        ]
        Effect   = "Allow",
        Resource = "${aws_secretsmanager_secret.TerraFailSecretsManager_secret.arn}"
      },
    ]
  })
}

# ---------------------------------------------------------------------
# KMS
# ---------------------------------------------------------------------
resource "aws_kms_key" "TerraFailSecretsManager_key" {
  # Drata: Define [aws_kms_key.policy] to restrict access to your resource. Follow the principal of minimum necessary access, ensuring permissions are scoped to trusted entities. Exclude this finding if access to Keys is managed using IAM policies instead of a Key policy
  description             = "TerraFailSecretsManager key description"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  key_usage               = "ENCRYPT_DECRYPT"
  tags = {
    Name = "TerraFailSecretsManager_key"
  }
}
