

# ---------------------------------------------------------------------
# ApiGateway
# ---------------------------------------------------------------------
resource "aws_api_gateway_account" "sac_api_gateway_account" {
  depends_on = [
    aws_iam_role_policy_attachment.sac_api_gateway_policy_attachment,
    aws_iam_role_policy.sac_api_gateway_role_policy
  ]
}

resource "aws_api_gateway_resource" "sac_api_gateway" {
  rest_api_id = aws_api_gateway_rest_api.sac_api_gateway_rest_api.id
  parent_id   = aws_api_gateway_rest_api.sac_api_gateway_rest_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_integration" "sac_api_gateway_integration" {
  rest_api_id = aws_api_gateway_rest_api.sac_api_gateway_rest_api.id
  resource_id = aws_api_gateway_resource.sac_api_gateway.id
  http_method = aws_api_gateway_method.sac_api_gateway_method.http_method
  type        = "MOCK"
  depends_on  = [aws_api_gateway_method.sac_api_gateway_method]
}

resource "aws_api_gateway_deployment" "sac_api_gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.sac_api_gateway_rest_api.id
  description = "SaC testing api-gw deployment"
  stage_description = "SaC testing api-gw deployment stage"
  stage_name        = "sac-apigw-deployment-stage-attachment"

  depends_on = [aws_api_gateway_method.sac_api_gateway_method]
}

resource "aws_api_gateway_domain_name" "sac_api_gateway_domain_name" {
  certificate_arn = aws_acm_certificate_validation.example.certificate_arn
  domain_name     = "api.example.com"
  security_policy = "tls_1_1"
}

resource "aws_api_gateway_api_key" "sac_api_gateway_key" {
  name        = "sac-testing-apigw-key"
  description = "API key for SaC API Gateway"
  enabled     = true
}

resource "aws_api_gateway_method_settings" "sac_api_gateway_method_settings" {
  rest_api_id = aws_api_gateway_rest_api.sac_api_gateway_rest_api.id
  stage_name  = aws_api_gateway_stage.sac_api_gateway_stage.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "ERROR"
    caching_enabled = false
    cache_data_encrypted = false
  }
}

resource "aws_api_gateway_method" "sac_api_gateway_method" {
  rest_api_id = aws_api_gateway_rest_api.sac_api_gateway_rest_api.id
  resource_id = aws_api_gateway_resource.sac_api_gateway.id
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_rest_api" "sac_api_gateway_rest_api" {
  name = "sac-testing-apigw-rest-api"

  endpoint_configuration {
    types = ["EDGE"]
  }

    policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": "execute-api:Invoke",
        "Resource": "*"
      }
    ]
  }
  EOF
}

resource "aws_api_gateway_usage_plan" "sac_api_gateway_usage_plan" {
  name = "sac-testing-apigw-usage-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.sac_api_gateway_rest_api.id
    stage  = aws_api_gateway_stage.sac_api_gateway_stage.stage_name
  }
}

resource "aws_api_gateway_stage" "sac_api_gateway_stage" {
  deployment_id = aws_api_gateway_deployment.sac_api_gateway_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.sac_api_gateway_rest_api.id
  stage_name    = "sac-testing-apigw-stage"

  depends_on = [
    aws_api_gateway_account.sac_api_gateway_account
  ]
}

# ---------------------------------------------------------------------
# Lambda
# ---------------------------------------------------------------------
resource "aws_lambda_function" "sac_api_gateway_lambda_function" {
  filename      = "${path.module}/foo.zip"
  function_name = "sac-testing-apigw-lambda"
  role          = aws_iam_role.sac_api_gateway_role.arn

  runtime = "nodejs12.x"
  handler = "index.test"
}

# ---------------------------------------------------------------------
# IAM
# ---------------------------------------------------------------------
resource "aws_iam_role" "sac_api_gateway_role" {
  name = "sac-testing-apigw-cloudwatch-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": ["apigateway.amazonaws.com","lambda.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "sac_api_gateway_role_policy" {
  name = "sac-testing-apigw-cloudwatch-role-policy"
  role = aws_iam_role.sac_api_gateway_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "sac_api_gateway_policy_attachment" {
  role       = aws_iam_role.sac_api_gateway_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}


# ---------------------------------------------------------------------
# CloudWatch
# ---------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "sac_api_gateway_cloudwatch_log_group" {
  name = "sac-testing-apigw-cloudwatch-log-group"

  tags = {
    Environment = "production"
  }
}
