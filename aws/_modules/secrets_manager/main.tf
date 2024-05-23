

# ---------------------------------------------------------------------
# SecretsManager
# ---------------------------------------------------------------------
resource "aws_secretsmanager_secret_rotation" "secrets_manager_rotation" {
  secret_id           = aws_secretsmanager_secret.sac_secrets_manager_insecure.id
  rotation_lambda_arn = aws_lambda_function.secure_lambda_SAC.arn

  rotation_rules {
    automatically_after_days = 90
  }
}

resource "aws_secretsmanager_secret" "sac_secrets_manager_insecure" {
  name                    = "sac-testing-secrets-manager-insecure"
  description             = "Default config2"
  recovery_window_in_days = 10
}

resource "aws_secretsmanager_secret_policy" "sac_secrets_manager_policy" {
  secret_arn = aws_secretsmanager_secret.sac_secrets_manager_insecure.arn

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
resource "aws_lambda_function" "secure_lambda_SAC" {
  function_name                  = "secure_lambda_function"
  role                           = aws_iam_role.lambda_role.arn
  filename                       = "my-deployment-package.zip"
  handler                        = "index.handler"
  runtime                        = "dotnet6"
  reserved_concurrent_executions = 2
  kms_key_arn                    = aws_kms_key.sac_kms_key.arn

  tags = {
    Name = "foo function"
  }

  vpc_config {
    subnet_ids         = [aws_subnet.test-subnet.id]
    security_group_ids = [aws_security_group.security-group-lambda.id]
  }

  dead_letter_config {
    target_arn = aws_sns_topic.topic-sns.arn
  }
}

resource "aws_lambda_permission" "rotation_lambda_permission" {
  function_name = aws_lambda_function.secure_lambda_SAC.function_name
  statement_id  = "AllowExecutionSecretManager"
  action        = "lambda:InvokeFunction"
  principal     = "secretsmanager.amazonaws.com"
}

# ---------------------------------------------------------------------
# SNS
# ---------------------------------------------------------------------
resource "aws_sns_topic" "topic-sns" {
  name = "user-updates-topic"
}

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "aws_security_group" "security-group-lambda" {
  vpc_id = aws_vpc.main.id
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_subnet" "test-subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Main"
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}


# ---------------------------------------------------------------------
# IAM
# ---------------------------------------------------------------------
resource "aws_iam_role" "lambda_role" {
  name               = "lambda_role"
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

resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = aws_iam_role.lambda_role.id
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
        Resource = "${aws_secretsmanager_secret.sac_secrets_manager_insecure.arn}"
      },
    ]
  })
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
