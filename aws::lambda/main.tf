

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
    # on_failure {  # SaC Testing - Severity: Low - Set on_failure to undefined
    #   destination = aws_sns_topic.topic-sns.arn 
    # }
    on_success {
      destination = aws_sns_topic.topic-sns.arn
    }
  }
}

resource "aws_lambda_event_source_mapping" "example" {
  event_source_arn  = aws_kinesis_stream.test_stream.arn
  function_name     = aws_lambda_function.insecure_lambda_SAC.arn
  starting_position = "LATEST"
  destination_config {
    # on_failure {  # SaC Testing - Severity: Low - Set on_failure to undefined
    #   destination_arn = aws_sns_topic.topic-sns.arn  
    # }
  }
}

resource "aws_lambda_function" "insecure_lambda_SAC" {
  function_name                  = "insecure_lambda_function"
  role                           = aws_iam_role.lambda_role.arn
  filename                       = "my-deployment-package.zip"
  handler                        = "index.handler"
  runtime                        = "dotnetcore3.1" # SaC Testing - Severity: Moderate - Set runtime to non-preferred value
  reserved_concurrent_executions = 0               # SaC Testing - Severity: Low - Set reserved_concurrent_executions to 0
  # kms_key_arn = aws_kms_key.foo_lambda.arn  # SaC Testing - Severity: Critical - Set kms_key_arn to ""
  layers = [aws_lambda_layer_version.lambda_layer.arn]
  # SaC Testing - Severity: Moderate - Set tags to undefined
  # tags = {
  #   Name = "foo function"
  # }
  # vpc_config {  # SaC Testing - Severity: Low - Set vpc_config to undefined
  #   subnet_ids = [aws_subnet.test-subnet.id]
  #   security_group_ids = [aws_security_group.security-group-lambda.id]
  # }
  # dead_letter_config {  # SaC Testing - Severity: Low - Set dead_letter_config to undefined
  #   target_arn = aws_sns_topic.topic-sns.arn
  # }
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  action        = "*" # SaC Testing - Severity: Critical - Set action to *
  function_name = aws_lambda_function.insecure_lambda_SAC.arn
  principal     = "*" # SaC Testing - Severity: Critical - Set principal to *
}

resource "aws_lambda_layer_version_permission" "lambda_layer_permission" {
  layer_name     = "arn:aws:lambda:us-east-2:709695003849:layer:lambda_layer_name"
  version_number = 4
  principal      = "*" # SaC Testing - Severity: Critical - Set principal to *
  # Drata: Explicitly scope [aws_lambda_layer_version_permission.principal] principal to ensure minimum necessary access. Avoid using insecure allow-all (*) access patterns
  action         = "*" # SaC Testing - Severity: Critical - Set action to ""
  # Drata: Explicitly scope [aws_lambda_layer_version_permission.action] action to ensure minimum necessary access. Avoid using insecure allow-all (*) access patterns
  statement_id   = "dev-account"
}

resource "aws_lambda_layer_version" "lambda_layer" {
  layer_name          = "lambda_layer_name"
  compatible_runtimes = ["ruby2.7"] # SaC Testing - Severity: Moderate - Set compatible_runtimes to non-preferred value
  description         = "test description for a test config"
  filename            = "my-deployment-package.zip"
}
