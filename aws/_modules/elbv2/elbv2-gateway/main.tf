

# ---------------------------------------------------------------------
# ELBv2
# ---------------------------------------------------------------------
resource "aws_lb" "elbv2_sac" {
  name                       = "elbv2-sac"
  load_balancer_type         = "gateway"
  drop_invalid_header_fields = true
  desync_mitigation_mode = "monitor"
  internal = false

  subnet_mapping {
    subnet_id = aws_subnet.elbv2_subnet_2.id
  }

  access_logs {
    bucket = aws_s3_bucket.elbv2_bucket.bucket
    enabled = false
  }
}

resource "aws_lb_listener_rule" "elbv2-listener-rule" {
  listener_arn = aws_lb_listener.elbv2_listener.arn

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.elbv2_target_group.arn

    authenticate_oidc {
      on_unauthenticated_request = "allow"
      session_cookie_name = "sac-testing-cookie"
      session_timeout        = 300
      client_id              = ""
      client_secret          = ""
      issuer                 = "https://oak9.okta.com/oauth2/default"
      token_endpoint         = "https://oak9.okta.com/oauth2/default/v1/token"
      authorization_endpoint = "https://oak9.okta.com/oauth2/default/v1/authorize"
      user_info_endpoint     = "https://oak9.okta.com/oauth2/default/v1/userinfo"
    }
  }

  condition {
    host_header {
      values = ["example.com"]
    }
  }
}

resource "aws_lb_listener" "elbv2_listener" {
  load_balancer_arn = aws_lb.elbv2_sac.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.elbv2_target_group.arn

    authenticate_oidc {
      on_unauthenticated_request = "allow"
      session_cookie_name = "sac-testing-cookie"
      session_timeout        = 300
      client_id              = ""
      client_secret          = ""
      issuer                 = "https://oak9.okta.com/oauth2/default"
      token_endpoint         = "https://oak9.okta.com/oauth2/default/v1/token"
      authorization_endpoint = "https://oak9.okta.com/oauth2/default/v1/authorize"
      user_info_endpoint     = "https://oak9.okta.com/oauth2/default/v1/userinfo"
    }
  }
}

resource "aws_lb_target_group_attachment" "elbv2_target_group_attachment" {
  target_group_arn = aws_lb_target_group.elbv2_target_group.arn
  target_id        = aws_instance.aws_ec2_instance_sac_default.id
}

resource "aws_lb_target_group" "elbv2_target_group" {
  name        = "elbv2-target-group-sac"
  target_type = "instance"
  vpc_id = aws_vpc.ec2_instance_vpc_default.id
  port   = 80
  protocol = "TCP"

  health_check {
    enabled = true
    protocol = "HTTP"
  }

  stickiness {
    enabled = false
    type = "source_ip"
  }
}

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "aws_subnet" "elbv2_subnet_1" {
  vpc_id            = aws_vpc.ec2_instance_vpc_default.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-2c"

  tags = {
    Name = "Main"
  }
}

resource "aws_subnet" "elbv2_subnet_2" {
  vpc_id            = aws_vpc.ec2_instance_vpc_default.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "Main"
  }
}

resource "aws_subnet" "ec2_instance_subnet_default" {
  vpc_id     = aws_vpc.ec2_instance_vpc_default.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Main"
  }
}

resource "aws_vpc" "ec2_instance_vpc_default" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_security_group" "ec2_instance_security_group_default" {
  name                   = "ec2-instance-security-group-default"
  description            = "Allow TLS inbound traffic"
  vpc_id                 = aws_vpc.ec2_instance_vpc_default.id
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
resource "aws_s3_bucket" "elbv2_bucket" {
  bucket = "elbv2-bucket"
  acl    = "public-read-write"
}

# ---------------------------------------------------------------------
# EC2-Instance
# ---------------------------------------------------------------------
resource "aws_instance" "aws_ec2_instance_sac_default" {
  ami                  = data.aws_ami.ubuntu.id
  subnet_id            = aws_subnet.ec2_instance_subnet_default.id
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile_default.name

  launch_template {
    id = aws_launch_template.aws_ec2_launch_template_sac_default.id
  }

  associate_public_ip_address = false
  availability_zone = "us-east-2c"
  monitoring = true
  vpc_security_group_ids = [aws_security_group.ec2_instance_security_group_default.id]

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
resource "aws_iam_instance_profile" "ec2_instance_profile_default" {
  name = "ec2-instance-profile-default"
  role = aws_iam_role.ec2_instance_role_default.name
}

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
# KMS
# ---------------------------------------------------------------------
resource "aws_kms_key" "ec2_instance_kms_key_default" {
  description             = "Instance-key"
  deletion_window_in_days = 10
}
