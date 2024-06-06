

# ---------------------------------------------------------------------
# ELBv2
# ---------------------------------------------------------------------
resource "aws_lb" "TerraFailLB" {
  name                       = "TerraFailLB"
  load_balancer_type         = "gateway"
  drop_invalid_header_fields = true
  desync_mitigation_mode     = "monitor"
  internal                   = false

  subnet_mapping {
    subnet_id = aws_subnet.TerraFailLB_subnet_2.id
  }

  access_logs {
    bucket  = aws_s3_bucket.TerraFailLB_bucket.bucket
    enabled = false
  }
}

resource "aws_lb_listener_rule" "TerraFailLB_listener_rule" {
  listener_arn = aws_lb_listener.TerraFailLB_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TerraFailLB_target_group.arn

    authenticate_oidc {
      on_unauthenticated_request = "allow"
      session_cookie_name        = "TerraFailLB_listener_rule_cookie"
      session_timeout            = 300
      client_id                  = ""
      client_secret              = ""
      issuer                     = "https://oak9.okta.com/oauth2/default"
      token_endpoint             = "https://oak9.okta.com/oauth2/default/v1/token"
      authorization_endpoint     = "https://oak9.okta.com/oauth2/default/v1/authorize"
      user_info_endpoint         = "https://oak9.okta.com/oauth2/default/v1/userinfo"
    }
  }

  condition {
    host_header {
      values = ["example.com"]
    }
  }
}

resource "aws_lb_listener" "TerraFailLB_listener" {
  load_balancer_arn = aws_lb.TerraFailLB.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TerraFailLB_target_group.arn

    authenticate_oidc {
      on_unauthenticated_request = "allow"
      session_cookie_name        = "TerraFailLB_listener_cookie"
      session_timeout            = 300
      client_id                  = ""
      client_secret              = ""
      issuer                     = "https://oak9.okta.com/oauth2/default"
      token_endpoint             = "https://oak9.okta.com/oauth2/default/v1/token"
      authorization_endpoint     = "https://oak9.okta.com/oauth2/default/v1/authorize"
      user_info_endpoint         = "https://oak9.okta.com/oauth2/default/v1/userinfo"
    }
  }
}

resource "aws_lb_target_group_attachment" "TerraFailLB_target_group_attachment" {
  target_group_arn = aws_lb_target_group.TerraFailLB_target_group.arn
  target_id        = aws_instance.TerraFailLB_instance.id
}

resource "aws_lb_target_group" "TerraFailLB_target_group" {
  name        = "TerraFailLB_target_group"
  target_type = "instance"
  vpc_id      = aws_vpc.TerraFailLB_vpc.id
  port        = 80
  protocol    = "TCP"

  health_check {
    enabled  = true
    protocol = "HTTP"
  }

  stickiness {
    enabled = false
    type    = "source_ip"
  }
}

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "aws_subnet" "TerraFailLB_subnet" {
  vpc_id            = aws_vpc.TerraFailLB_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-2c"

  tags = {
    Name = "TerraFailLB_subnet"
  }
}

resource "aws_subnet" "TerraFailLB_subnet_2" {
  vpc_id            = aws_vpc.TerraFailLB_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "TerraFailLB_subnet_2"
  }
}

resource "aws_subnet" "TerraFailLB_subnet_default" {
  vpc_id     = aws_vpc.TerraFailLB_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "TerraFailLB_subnet_default"
  }
}

resource "aws_vpc" "TerraFailLB_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_security_group" "TerraFailLB_security_group" {
  name                   = "TerraFailLB_security_group"
  description            = "Allow TLS inbound traffic"
  vpc_id                 = aws_vpc.TerraFailLB_vpc.id
  revoke_rules_on_delete = false

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------------------------------------------------------------
# S3
# ---------------------------------------------------------------------
resource "aws_s3_bucket" "TerraFailLB_bucket" {
  bucket = "TerraFailLB_bucket"
  acl    = "public-read-write"
}

# ---------------------------------------------------------------------
# EC2-Instance
# ---------------------------------------------------------------------
resource "aws_instance" "TerraFailLB_instance" {
  ami                  = data.aws_ami.ubuntu.id
  subnet_id            = aws_subnet.TerraFailLB_subnet_default.id
  iam_instance_profile = aws_iam_instance_profile.TerraFailLB_instance_profile.name

  launch_template {
    id = aws_launch_template.TerraFailLB_launch_template.id
  }

  associate_public_ip_address = false
  availability_zone           = "us-east-2c"
  monitoring                  = true
  vpc_security_group_ids      = [aws_security_group.TerraFailLB_security_group.id]

  tags = {
    name = "TerraFailLB_instance"
  }

  ebs_block_device {
    delete_on_termination = false
    device_name           = "/dev/sdf"
    encrypted             = true
    kms_key_id            = aws_kms_key.TerraFailLB_key.id
    volume_size           = 5

    tags = {
      name = "TerraFailLB_instance"
    }
  }
}

resource "aws_launch_template" "TerraFailLB_launch_template" {
  name                                 = "TerraFailLB_launch_template"
  default_version                      = 1
  disable_api_stop                     = false
  disable_api_termination              = false
  ebs_optimized                        = true
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = "t2.micro"

  tags = {
    name = "TerraFailLB_launch_template"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
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

# ---------------------------------------------------------------------
# IAM
# ---------------------------------------------------------------------
resource "aws_iam_instance_profile" "TerraFailLB_instance_profile" {
  name = "TerraFailLB_instance_profile"
  role = aws_iam_role.TerraFailLB_role.name
}

resource "aws_iam_role" "TerraFailLB_role" {
  name = "TerraFailLB_role"
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
# KMS
# ---------------------------------------------------------------------
resource "aws_kms_key" "TerraFailLB_key" {
  description             = "TerraFailLB_key"
  deletion_window_in_days = 10
}
