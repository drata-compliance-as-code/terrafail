

# ---------------------------------------------------------------------
# ApiGateway
# ---------------------------------------------------------------------
resource "aws_api_gateway_account" "sac_api_gateway_account" {
  #cloudwatch_role_arn = aws_iam_role.sac_api_gateway_role.arn  # SaC Testing - Severity: Critical - Set cloudwatch_role_arn to ""
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
  rest_api_id       = aws_api_gateway_rest_api.sac_api_gateway_rest_api.id
  description       = "SaC testing api-gw deployment"
  stage_description = "SaC testing api-gw deployment stage"
  stage_name        = "sac-apigw-deployment-stage-attachment"
  depends_on        = [aws_api_gateway_method.sac_api_gateway_method]
}

resource "aws_api_gateway_domain_name" "sac_api_gateway_domain_name" {
  certificate_arn = aws_acm_certificate_validation.example.certificate_arn
  domain_name     = "api.example.com"
  security_policy = "tls_1_1" # SaC Testing - Severity: Critical - set security_policy != 'tls_1_2'

  # SaC Testing - Severity: Critical - set mutual_tls_authentication to undefined
  #   mutual_tls_authentication { # SaC Testing - Severity: Critical - set mutual_tls_authentication to undefined
  #     truststore_uri = "s3://bucket-name/key-name"
  #     truststore_version = 1
  #   }

  # SaC Testing - Severity: Moderate - set tags to undefined
  #   tags = {
  #     key = "value"
  #   }  
}

resource "aws_api_gateway_api_key" "sac_api_gateway_key" {
  name        = "sac-testing-apigw-key"
  description = "API key for SaC API Gateway"
  enabled     = true
  # SaC Testing - Severity: Moderate - set tags to undefined
  # tags = {
  #   Environment = "production"
  # }
}

resource "aws_api_gateway_method_settings" "sac_api_gateway_method_settings" {
  rest_api_id = aws_api_gateway_rest_api.sac_api_gateway_rest_api.id
  stage_name  = aws_api_gateway_stage.sac_api_gateway_stage.stage_name
  method_path = "*/*"
  settings {
    metrics_enabled      = true
    logging_level        = "ERROR"
    caching_enabled      = false # SaC Testing - Severity: Critical - Set caching_enabled to false
    cache_data_encrypted = false # SaC Testing - Severity: Critical - Set cache_data_encrypted to false
  }
}

resource "aws_api_gateway_method" "sac_api_gateway_method" {
  rest_api_id   = aws_api_gateway_rest_api.sac_api_gateway_rest_api.id
  resource_id   = aws_api_gateway_resource.sac_api_gateway.id
  http_method   = "GET"
  authorization = "NONE" # SaC Testing - Severity: Critical - Set authorization to non-preferred value
  authorizer_id = ""     # SaC Testing - Severity: Critical - Set authorizer_id to ""
  #request_validator_id = aws_api_gateway_request_validator.sac_api_gateway_request_validator.id  # SaC Testing - Severity: Moderate - Set request_validator_id to undefined
}

resource "aws_api_gateway_rest_api" "sac_api_gateway_rest_api" {
  name = "sac-testing-apigw-rest-api"
  # SaC Testing - Severity: Moderate - set tags to undefined
  # tags = {
  #   key = "value"
  # }
  endpoint_configuration {
    types = ["EDGE"]
  }
  #   policy = <<EOF  # SaC Testing - Severity: High - Set policy to undefined
  # {
  #   "Version": "2012-10-17",
  #   "Statement": [
  #     {
  #       "Effect": "Allow",
  #       "Principal": "*",
  #       "Action": "execute-api:Invoke",
  #       "Resource": "*"
  #     }
  #   ]
  # }
  # EOF
}

resource "aws_api_gateway_usage_plan" "sac_api_gateway_usage_plan" {
  name = "sac-testing-apigw-usage-plan"
  # SaC Testing - Severity: Moderate - set tags to undefined
  # tags = {
  #   key = "value"
  # }
  api_stages {
    api_id = aws_api_gateway_rest_api.sac_api_gateway_rest_api.id
    stage  = aws_api_gateway_stage.sac_api_gateway_stage.stage_name
  }
}

resource "aws_api_gateway_stage" "sac_api_gateway_stage" {
  # Drata: Configure [aws_api_gateway_stage.access_log_settings] to ensure that security-relevant events are logged to detect malicious activity
  deployment_id = aws_api_gateway_deployment.sac_api_gateway_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.sac_api_gateway_rest_api.id
  stage_name    = "sac-testing-apigw-stage"
  # access_log_settings { # SaC Testing - Severity: Moderate - Set access_log_settings to undefined
  #   destination_arn = aws_cloudwatch_log_group.sac_api_gateway_cloudwatch_log_group.arn
  #   format          = "$context.requestId"
  # }
  # SaC Testing - Severity: Moderate - set tags to undefined
  # tags = {
  #   Environment = "production"
  # }
  depends_on = [
    aws_api_gateway_account.sac_api_gateway_account
  ]
}
