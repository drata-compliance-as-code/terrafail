

# ---------------------------------------------------------------------
# Lambda
# ---------------------------------------------------------------------
resource "aws_lambda_alias" "TerraFailLambda_alias" {
  name             = "TerraFailLambda_alias"
  function_name    = aws_lambda_function.TerraFailLambda_function.arn
  function_version = "$LATEST"
}

resource "aws_lambda_function_event_invoke_config" "TerraFailLambda_event_invoke_config" {
  function_name = aws_lambda_alias.TerraFailLambda_alias.arn

  destination_config {
    on_success {
      destination = aws_sns_topic.TerraFailLambda_topic.arn
    }
  }
}

resource "aws_lambda_event_source_mapping" "TerraFailLambda_event_source_mapping" {
  event_source_arn  = aws_kinesis_stream.TerraFailLambda_stream.arn
  function_name     = aws_lambda_function.TerraFailLambda_function.arn
  starting_position = "LATEST"
}

resource "aws_lambda_function" "TerraFailLambda_function" {
  function_name                  = "TerraFailLambda_function"
  role                           = aws_iam_role.TerraFailLambda_role.arn
  filename                       = "my-deployment-package.zip"
  handler                        = "index.handler"
  runtime                        = "dotnetcore3.1"
  reserved_concurrent_executions = 0
  layers                         = [aws_TerraFailLambda_layer_version_version.TerraFailLambda_layer_version.arn]
}

resource "aws_lambda_permission" "TerraFailLambda_permission" {
  action        = "*"
  function_name = aws_lambda_function.TerraFailLambda_function.arn
  principal     = "*"
}

resource "aws_TerraFailLambda_layer_version_version_permission" "TerraFailTerraFailLambda_layer_version_permission" {
  layer_name     = "arn:aws:lambda:us-east-2:709695003849:layer:TerraFailLambda_layer_version_name"
  version_number = 1
  principal      = "*"
  action         = "*"
  statement_id   = "dev-account"
}

resource "aws_TerraFailLambda_layer_version_version" "TerraFailLambda_layer_version" {
  layer_name          = "TerraFailLambda_layer_version"
  compatible_runtimes = ["ruby2.7"]
  description         = "test description for a test config"
  filename            = "my-deployment-package.zip"
}

# ---------------------------------------------------------------------
# Kinesis
# ---------------------------------------------------------------------
resource "aws_kinesis_stream" "TerraFailLambda_stream" {
  name             = "TerraFailLambda_stream"
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
    Environment = "sandbox"
  }
}

# ---------------------------------------------------------------------
# SNS
# ---------------------------------------------------------------------
resource "aws_sns_topic" "TerraFailLambda_topic" {
  name = "TerraFailLambda_topic"
}

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "aws_security_group" "TerraFailLambda_security_group" {
  vpc_id = aws_vpc.TerraFailLambda_vpc.id
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_subnet" "TerraFailLambda_subnet" {
  vpc_id     = aws_vpc.TerraFailLambda_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "TerraFailLambda_vpc"
  }
}

resource "aws_vpc" "TerraFailLambda_vpc" {
  cidr_block = "10.0.0.0/16"
}

# ---------------------------------------------------------------------
# IAM
# ---------------------------------------------------------------------
resource "aws_iam_role" "TerraFailLambda_role" {
  name               = "TerraFailLambda_role"
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

resource "aws_iam_role_policy" "TerraFailLambda_policy" {
  name = "TerraFailLambda_policy"
  role = aws_iam_role.TerraFailLambda_role.id
  policy = jsonencode({
    # Drata: Explicitly define resources for [aws_iam_role.inline_policy.policy] in adherence with the principal of least privilege. Avoid the use of overly permissive allow-all access patterns such as ([*])
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
