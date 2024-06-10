

# ---------------------------------------------------------------------
# ApiGateway
# ---------------------------------------------------------------------
resource "aws_apigatewayv2_api" "TerraFailAPIv2" {
  name          = "TerraFailAPIv2"
  protocol_type = "WEBSOCKET"
}

resource "aws_apigatewayv2_api_mapping" "TerraFailAPIv2_mapping" {
  api_id      = aws_apigatewayv2_api.TerraFailAPIv2.id
  domain_name = aws_apigatewayv2_domain_name.TerraFailAPIv2_domain.id
  stage       = aws_apigatewayv2_stage.TerraFailAPIv2_stage.id
}

resource "aws_apigatewayv2_domain_name" "TerraFailAPIv2_domain" {
  domain_name = "thisisthedarkside.com"
  domain_name_configuration {
    certificate_arn = "arn:aws:acm:us-east-2:709695003849:certificate/2c0bef53-a821-4722-939e-d3c29a2dd3b3"
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_1"
  }
}

resource "aws_apigatewayv2_integration" "TerraFailAPIv2_integration" {
  api_id             = aws_apigatewayv2_api.TerraFailAPIv2.id
  integration_type   = "AWS_PROXY"
  integration_method = "PATCH"
  connection_type    = "INTERNET"
  integration_uri    = aws_lambda_function.TerraFailAPIv2_lambda_function.arn
}

resource "aws_apigatewayv2_stage" "TerraFailAPIv2_stage" {
  api_id = aws_apigatewayv2_api.TerraFailAPIv2.id
  name   = "TerraFailAPIv2_stage"

  default_route_settings {
    detailed_metrics_enabled = false
    logging_level            = "OFF"
  }
}

resource "aws_apigatewayv2_route" "TerraFailAPIv2_route" {
  api_id             = aws_apigatewayv2_api.TerraFailAPIv2.id
  route_key          = "$connect"
  authorization_type = "NONE"
  api_key_required   = false
  target             = "integrations/${aws_apigatewayv2_integration.TerraFailAPIv2_integration.id}"
}

# ---------------------------------------------------------------------
# Route53
# ---------------------------------------------------------------------
resource "aws_route53_zone" "TerraFailAPIv2_route_zone" {
  name = "thisisthedarkside.com"
}

resource "aws_route53_record" "TerraFailAPIv2_route_record" {
  zone_id = aws_route53_zone.TerraFailAPIv2_route_zone.id
  name    = "thisisthedarkside.com"
  type    = "A"
  ttl     = 300
  records = ["192.0.2.1"]
}

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "aws_vpc" "TerraFailAPIv2_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "apigwv2-vpc"
  }
}

resource "aws_internet_gateway" "TerraFailAPIv2_gateway" {
  vpc_id = aws_vpc.TerraFailAPIv2_vpc.id

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "TerraFailAPIv2_subnet" {
  vpc_id            = aws_vpc.TerraFailAPIv2_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-2c"

  map_public_ip_on_launch = true
  tags = {
    Name = "TerraFailAPIv2_subnet"
  }
}
resource "aws_subnet" "TerraFailAPIv2_subnet_2" {
  vpc_id            = aws_vpc.TerraFailAPIv2_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "Main"
  }
}

resource "aws_security_group" "TerraFailAPIv2_security_group" {
  name   = "TerraFailAPIv2_security_group"
  vpc_id = aws_vpc.TerraFailAPIv2_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["173.0.0.0/32"]
  }

  tags = {
    Name = "apigwv2_sec_group"
  }
}

# ---------------------------------------------------------------------
# Lambda
# ---------------------------------------------------------------------
resource "aws_lambda_function" "TerraFailAPIv2_lambda_function" {
  function_name = "TerraFailAPIv2_lambda_function"
  role          = aws_iam_role.TerraFailAPIv2_role.arn
  filename      = "my-deployment-package.zip"
  handler       = "index.handler"
  runtime = "dotnet6"
  reserved_concurrent_executions = 0
}

# ---------------------------------------------------------------------
# IAM
# ---------------------------------------------------------------------
resource "aws_iam_role" "TerraFailAPIv2_role" {
  name               = "TerraFailAPIv2_role"
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

resource "aws_iam_role_policy" "TerraFailAPIv2_iam_policy" {
  name = "TerraFailAPIv2_iam_policy"
  role = aws_iam_role.TerraFailAPIv2_role.id

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

# ---------------------------------------------------------------------
# CloudWatch
# ---------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "TerraFailAPIv2_cloudwatch_group" {
  name = "TerraFailAPIv2_cloudwatch_group"

  tags = {
    Environment = "production"
  }
}
