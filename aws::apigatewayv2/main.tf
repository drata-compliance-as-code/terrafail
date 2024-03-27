

# ---------------------------------------------------------------------
# ApiGateway
# ---------------------------------------------------------------------
resource "aws_apigatewayv2_api" "sac_apigwv2_api" {
  name          = "sac-testing-apigwv2-api"
  protocol_type = "HTTP"
  cors_configuration {
    allow_methods = ["*"] # SaC Testing - Severity: Moderate - Set allow_methods != ['get', 'put', 'post']
  }
  # SaC Testing - Severity: Moderate - set tags to undefined
  # tags = {
  #   Environment = "production"
  # }
}

resource "aws_apigatewayv2_api_mapping" "api" {
  api_id      = aws_apigatewayv2_api.sac_apigwv2_api.id
  domain_name = aws_apigatewayv2_domain_name.sac_apigwv2_domain.id
  stage       = aws_apigatewayv2_stage.sac_apigwv2_stage.id
}

resource "aws_apigatewayv2_domain_name" "sac_apigwv2_domain" {
  domain_name = "thisisthedarkside.com"
  # mutual_tls_authentication{  # SaC Testing - Severity: Moderate - set mutual_tls_authentication to undefined
  #  truststore_uri =  
  # }
  domain_name_configuration {
    certificate_arn = "arn:aws:acm:us-east-2:709695003849:certificate/2c0bef53-a821-4722-939e-d3c29a2dd3b3"
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_1" # SaC Testing - Severity: Critical - set security_policy != TLS_1_2
  }
  # SaC Testing - Severity: Moderate - set tags to undefined
  # tags = {
  #   Environment = "production"
  # }
}

resource "aws_apigatewayv2_integration" "sac_apigwv2_integration" {
  api_id             = aws_apigatewayv2_api.sac_apigwv2_api.id
  integration_type   = "HTTP"
  integration_method = "PATCH"    # SaC Testing - Severity: Moderate - set integration_method != ['get', 'put', 'post']
  connection_type    = "VPC_LINK" # SaC Testing - Severity: Moderate - set connection_type != vpc_link
  integration_uri    = aws_lb_listener.elbv2_listener.arn
  # tls_config { # SaC Testing - Severity: Critical - set tls_config to undefined
  #   server_name_to_verify = "thisisthedarkside.com"
  # }
}

resource "aws_apigatewayv2_stage" "sac_apigwv2_stage" {
  api_id = aws_apigatewayv2_api.sac_apigwv2_api.id
  name   = "sac-testing-apigwv2-stage"
  # access_log_settings { # SaC Testing - Severity: High - Set access_log_settings to undefined
  #   destination_arn = aws_cloudwatch_log_group.sac_api_gatewayv2_cloudwatch_log_group.arn
  #   format = "$context.requestId"
  # }
  # SaC Testing - Severity: Moderate - set tags to undefined
  # tags = {
  #   Environment = "production"
  # }
}

resource "aws_apigatewayv2_route" "sac_apigwv2_route" {
  api_id             = aws_apigatewayv2_api.sac_apigwv2_api.id
  route_key          = "GET /hello"
  authorization_type = "NONE" # SaC Testing - Severity: Critical - set authorization_type =!= ['aws_iam', 'custom', 'jwt']
  target             = "integrations/${aws_apigatewayv2_integration.sac_apigwv2_integration.id}"
}
