

# ---------------------------------------------------------------------
# Lambda
# ---------------------------------------------------------------------
resource "aws_lambda_alias" "test_lambda_alias" {
  name             = "alias-insecure-SaC"
  function_name    = aws_lambda_function.insecure_lambda_SAC.arn
  function_version = "$LATEST"
}

resource "aws_lambda_function_event_invoke_config" "example" {
  function_name = aws_lambda_alias.test_lambda_alias.arn

  destination_config {
    on_success {
      destination = aws_sns_topic.topic-sns.arn
    }
  }
}

resource "aws_lambda_event_source_mapping" "example" {
  event_source_arn  = aws_kinesis_stream.test_stream.arn
  function_name     = aws_lambda_function.insecure_lambda_SAC.arn
  starting_position = "LATEST"
}

resource "aws_lambda_function" "insecure_lambda_SAC" {
  function_name                  = "insecure_lambda_function"
  role                           = aws_iam_role.lambda_role.arn
  filename                       = "my-deployment-package.zip"
  handler                        = "index.handler"
  runtime                        = "dotnetcore3.1"
  reserved_concurrent_executions = 0
  layers                         = [aws_lambda_layer_version.lambda_layer.arn]
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  action        = "*"
  function_name = aws_lambda_function.insecure_lambda_SAC.arn
  principal     = "*"
}

resource "aws_lambda_layer_version_permission" "lambda_layer_permission" {
  layer_name     = "arn:aws:lambda:us-east-2:709695003849:layer:lambda_layer_name"
  version_number = 1
  principal      = "*"
  action         = "*"
  statement_id   = "dev-account"
}

resource "aws_lambda_layer_version" "lambda_layer" {
  layer_name          = "lambda_layer_name"
  compatible_runtimes = ["ruby2.7"]
  description         = "test description for a test config"
  filename            = "my-deployment-package.zip"
}

# ---------------------------------------------------------------------
# Kinesis
# ---------------------------------------------------------------------
resource "aws_kinesis_stream" "test_stream" {
  name             = "terraform-kinesis-test"
  shard_count      = 1
  retention_period = 48

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }

  tags = {
    Environment = "test"
  }
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
          "sns:Publish",
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeInstances",
          "ec2:AttachNetworkInterface",
          "kinesis:GetRecords",
          "kinesis:GetShardIterator",
          "kinesis:DescribeStream",
          "kinesis:ListShards",
          "kinesis:ListStreams",
          "lambda:GetLayerVersion",
          "lambda:InvokeFunction",
          "lambda:AddLayerVersionPermission",
          "lambda:AddPermission",
          "lamda:CreateAlias",
          "lambda:CreateEventSourceMapping",

        ]
        Effect   = "Allow",
        Resource = "*"
      },
    ]
  })
}
