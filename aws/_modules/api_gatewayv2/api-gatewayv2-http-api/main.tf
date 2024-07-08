

# ---------------------------------------------------------------------
# ApiGateway
# ---------------------------------------------------------------------
resource "aws_apigatewayv2_api" "TerraFailAPIv2" {
  name          = "TerraFailAPIv2"
  protocol_type = "HTTP"

  cors_configuration {
    allow_methods = ["*"]
  }
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
    security_policy = "tls_1_2"
  }
}

resource "aws_apigatewayv2_integration" "TerraFailAPIv2_integration" {
  api_id             = aws_apigatewayv2_api.TerraFailAPIv2.id
  integration_type   = "HTTP_PROXY"
  integration_method = "PATCH"
  connection_type    = "INTERNET"
  integration_uri    = aws_lb_listener.TerraFailAPIv2_listener.arn
  tls_config {
    server_name_to_verify = "thisisthedarkside.com"
  }
}

resource "aws_apigatewayv2_stage" "TerraFailAPIv2_stage" {
  api_id = aws_apigatewayv2_api.TerraFailAPIv2.id
  name   = "TerraFailAPIv2_stage"
}

resource "aws_apigatewayv2_route" "TerraFailAPIv2_route" {
  api_id             = aws_apigatewayv2_api.TerraFailAPIv2.id
  route_key          = "GET /hello"
  authorization_type = "NONE"
  target             = "integrations/${aws_apigatewayv2_integration.TerraFailAPIv2_integration.id}"
}

# ---------------------------------------------------------------------
# ELBV2
# ---------------------------------------------------------------------
resource "aws_lb" "TerraFailAPIv2_lb" {
  name                       = "TerraFailAPIv2_lb"
  load_balancer_type         = "application"
  drop_invalid_header_fields = true
  desync_mitigation_mode     = "monitor"
  internal                   = false
  subnets                    = [aws_subnet.TerraFailAPIv2_subnet.id, aws_subnet.TerraFailAPIv2_subnet_2.id]
}

resource "aws_lb_listener" "TerraFailAPIv2_listener" {
  load_balancer_arn = aws_lb.TerraFailAPIv2_lb.arn
  port              = 99

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TerraFailAPIv2_target_group.arn
  }

  depends_on = [
    aws_lb_target_group.TerraFailAPIv2_target_group
  ]
}

resource "aws_lb_target_group" "TerraFailAPIv2_target_group" {
  name        = "TerraFailAPIv2_lb"
  target_type = "instance"
  vpc_id      = aws_vpc.TerraFailAPIv2_vpc.id
  port        = 80
  protocol    = "HTTP"

  health_check {
    enabled  = true
    protocol = "HTTP"
  }
}

resource "aws_lb_target_group_attachment" "TerraFailAPIv2_target_group_attachment" {
  target_group_arn = aws_lb_target_group.TerraFailAPIv2_target_group.arn
  target_id        = aws_instance.TerraFailAPIv2_instance.id
}

# ---------------------------------------------------------------------
# EC2-Instance
# ---------------------------------------------------------------------
resource "aws_instance" "TerraFailAPIv2_instance" {
  ami                  = data.aws_ami.ubuntu.id
  subnet_id            = aws_subnet.TerraFailAPIv2_subnet.id
  iam_instance_profile = "TerraFailAPIv2_instance_profile"

  launch_template {
    id = aws_launch_template.TerraFailAPIv2_launch_template.id
  }

  associate_public_ip_address = false
  availability_zone           = "us-east-2c"
  monitoring                  = true
  vpc_security_group_ids      = [aws_security_group.TerraFailAPIv2_security_group.id]

  tags = {
    key = "value"
  }

  ebs_block_device {
    delete_on_termination = false
    device_name           = "/dev/sdf"
    encrypted             = true
    kms_key_id            = aws_kms_key.TerraFailAPIv2_key.id
    volume_size           = 5

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

resource "aws_launch_template" "TerraFailAPIv2_launch_template" {
  name                                 = "TerraFailAPIv2_launch_template"
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
resource "aws_route53_zone" "TerraFailAPIv2_route_zone" {
  name = "thisisthedarkside.com"
}

resource "aws_route53_record" "TerraFailAPIv2_route_record" {
  zone_id = aws_route53_zone.TerraFailAPIv2_route_zone.id
  name    = "thisisthedarkside.com"
  type    = "A" # API
  ttl     = 300
  records = ["192.0.2.1"]
}

# ---------------------------------------------------------------------
# KMS
# ---------------------------------------------------------------------
resource "aws_kms_key" "TerraFailAPIv2_key" {
  description             = "TerraFailAPIv2_key"
  deletion_window_in_days = 10
}

# ---------------------------------------------------------------------
# IAM
# ---------------------------------------------------------------------
resource "aws_iam_role" "TerraFailAPIv2_role" {
  name = "TerraFailAPIv2_role"
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
resource "aws_vpc" "TerraFailAPIv2_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "TerraFailAPIv2_vpc"
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
    env = "sandbox"
  }
}

# ---------------------------------------------------------------------
# CloudWatch
# ---------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "TerraFailAPIv2_cloudwatch_group" {
  name = "TerraFailAPIv2_cloudwatch_group"

  tags = {
    Environment = "sandbox"
  }
}
