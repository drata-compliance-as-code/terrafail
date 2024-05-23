

# ---------------------------------------------------------------------
# ApiGateway
# ---------------------------------------------------------------------
resource "aws_apigatewayv2_api" "sac_apigwv2_api" {
  name          = "sac-testing-apigwv2-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_methods = ["*"]
  }
}

resource "aws_apigatewayv2_api_mapping" "api" {
  api_id      = aws_apigatewayv2_api.sac_apigwv2_api.id
  domain_name = aws_apigatewayv2_domain_name.sac_apigwv2_domain.id
  stage       = aws_apigatewayv2_stage.sac_apigwv2_stage.id
}

resource "aws_apigatewayv2_domain_name" "sac_apigwv2_domain" {
  domain_name = "thisisthedarkside.com"

  domain_name_configuration {
    certificate_arn = "arn:aws:acm:us-east-2:709695003849:certificate/2c0bef53-a821-4722-939e-d3c29a2dd3b3"
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_1"
  }
}

resource "aws_apigatewayv2_integration" "sac_apigwv2_integration" {
  api_id           = aws_apigatewayv2_api.sac_apigwv2_api.id
  integration_type = "HTTP_PROXY"
  integration_method = "PATCH"
  connection_type = "INTERNET"
  integration_uri = aws_lb_listener.elbv2_listener.arn
  tls_config {
    server_name_to_verify = "thisisthedarkside.com"
  }
}

resource "aws_apigatewayv2_stage" "sac_apigwv2_stage" {
  api_id = aws_apigatewayv2_api.sac_apigwv2_api.id
  name   = "sac-testing-apigwv2-stage"
}

resource "aws_apigatewayv2_route" "sac_apigwv2_route" {
  api_id    = aws_apigatewayv2_api.sac_apigwv2_api.id
  route_key = "GET /hello"
  authorization_type = "NONE"
  target             = "integrations/${aws_apigatewayv2_integration.sac_apigwv2_integration.id}"
}

# ---------------------------------------------------------------------
# ELBV2
# ---------------------------------------------------------------------
resource "aws_lb" "elbv2_sac" {
  name               = "elbv2-sac"
  load_balancer_type = "application"
  drop_invalid_header_fields = true
  desync_mitigation_mode = "monitor"
  internal = false
  subnets  = [aws_subnet.apigwv2_subnet.id, aws_subnet.apigwv2_subnet_2.id]
}

resource "aws_lb_listener" "elbv2_listener" {
  load_balancer_arn = aws_lb.elbv2_sac.arn
  port              = 99

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.elbv2_target_group.arn
  }

  depends_on = [
    aws_lb_target_group.elbv2_target_group
  ]
}

resource "aws_lb_target_group" "elbv2_target_group" {
  name        = "elbv2-target-group-sac"
  target_type = "instance"
  vpc_id      = aws_vpc.apigwv2_vpc.id
  port        = 80
  protocol = "HTTP"

  health_check {
    enabled = true
    protocol = "HTTP"
  }
}

resource "aws_lb_target_group_attachment" "elbv2_target_group_attachment" {
  target_group_arn = aws_lb_target_group.elbv2_target_group.arn
  target_id        = aws_instance.aws_ec2_instance_sac_default.id
}

# ---------------------------------------------------------------------
# EC2-Instance
# ---------------------------------------------------------------------
resource "aws_instance" "aws_ec2_instance_sac_default" {
  ami                  = data.aws_ami.ubuntu.id
  subnet_id            = aws_subnet.apigwv2_subnet.id
  iam_instance_profile = "ec2-instance-profile-default"

  launch_template {
    id = aws_launch_template.aws_ec2_launch_template_sac_default.id
  }

  associate_public_ip_address = false
  availability_zone = "us-east-2c"
  monitoring = true
  vpc_security_group_ids = [aws_security_group.apigwv2_security_group.id]

  tags = {
    key = "value"
  }

  ebs_block_device {
    delete_on_termination = false
    device_name           = "/dev/sdf"
    encrypted = true
    kms_key_id  = aws_kms_key.ec2_instance_kms_key_default.id
    volume_size = 5

    tags = {
      "key" = "value"
    }
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

resource "aws_launch_template" "aws_ec2_launch_template_sac_default" {
  name                                 = "ec2-instance-launch-template-sac-default"
  default_version                      = 1
  disable_api_stop                     = false
  disable_api_termination              = false
  ebs_optimized                        = true
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = "t2.micro"

  tags = {
    "key" = "value"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }
}

# ---------------------------------------------------------------------
# Route53
# ---------------------------------------------------------------------
resource "aws_route53_zone" "sac_route_zone" {
  name = "thisisthedarkside.com"
}

resource "aws_route53_record" "sac_route_record" {
  zone_id = aws_route53_zone.sac_route_zone.id
  name    = "thisisthedarkside.com"
  type    = "A" # API
  ttl     = 300
  records = ["192.0.2.1"]
}

# ---------------------------------------------------------------------
# KMS
# ---------------------------------------------------------------------
resource "aws_kms_key" "ec2_instance_kms_key_default" {
  description             = "Instance-key"
  deletion_window_in_days = 10
}

# ---------------------------------------------------------------------
# IAM
# ---------------------------------------------------------------------
resource "aws_iam_role" "ec2_instance_role_default" {
  name = "ec2-instance-role-default"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "aws_vpc" "apigwv2_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "apigwv2-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.apigwv2_vpc.id

  tags = {
    Name = "main"
  }
}
resource "aws_subnet" "apigwv2_subnet" {
  vpc_id            = aws_vpc.apigwv2_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-2c"

  map_public_ip_on_launch = true
  tags = {
    Name = "apigwv2_subnet"
  }
}
resource "aws_subnet" "apigwv2_subnet_2" {
  vpc_id            = aws_vpc.apigwv2_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "Main"
  }
}

resource "aws_security_group" "apigwv2_security_group" {
  name   = "apigwv2-security-group"
  vpc_id = aws_vpc.apigwv2_vpc.id

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
# CloudWatch
# ---------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "sac_api_gatewayv2_cloudwatch_log_group" {
  name = "sac-testing-apigwv2-cloudwatch-log-group"

  tags = {
    Environment = "production"
  }
}
