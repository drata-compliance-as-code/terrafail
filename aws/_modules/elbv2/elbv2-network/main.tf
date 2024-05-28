

# ---------------------------------------------------------------------
# ELBv2
# ---------------------------------------------------------------------
resource "aws_lb" "TerraFailLB" {
  name                       = "TerraFailLB"
  load_balancer_type         = "network"
  drop_invalid_header_fields = true
  desync_mitigation_mode     = "monitor"
  internal                   = true
  subnets                    = [aws_subnet.TerraFailLB_subnet.id]

  access_logs {
    bucket  = aws_s3_bucket.TerraFailLB_bucket.bucket
    enabled = false
  }
}

resource "aws_lb_listener" "TerraFailLB_listener" {
  load_balancer_arn = aws_lb.TerraFailLB.arn
  port              = 99
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TerraFailLB_target_group.arn

    authenticate_cognito {
      user_pool_arn       = aws_cognito_user_pool.TerraFailLB_cognito_user_pool.arn
      user_pool_client_id = aws_cognito_user_pool_client.TerraFailLB_cognito_user_pool_client.id
      user_pool_domain    = aws_cognito_user_pool_domain.TerraFailLB_cognito_user_pool_domain.domain
      authentication_request_extra_params = {
        key = "value"
      }

      on_unauthenticated_request = "allow"
      session_timeout            = 1000
    }
  }
}

resource "aws_lb_target_group" "TerraFailLB_target_group" {
  name        = "TerraFailLB_target_group"
  target_type = "instance"
  vpc_id      = aws_vpc.TerraFailLB_vpc.id
  port        = 80
  protocol    = "TCP"

  health_check {
    enabled  = false
    protocol = "HTTP"
  }

  stickiness {
    enabled = false
    type    = "source_ip"
  }
}

resource "aws_lb_target_group_attachment" "TerraFailLB_target_group_attachment" {
  target_group_arn = aws_lb_target_group.TerraFailLB_target_group.arn
  target_id        = aws_instance.TerraFailLB_instance.id
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
    key = "TerraFailLB_instance"
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

# ---------------------------------------------------------------------
# S3
# ---------------------------------------------------------------------
resource "aws_s3_bucket" "TerraFailLB_bucket" {
  bucket = "TerraFailLB_bucket"
  acl    = "public-read-write"
}

# ---------------------------------------------------------------------
# Cognito User Pool
# ---------------------------------------------------------------------
resource "aws_cognito_user_pool" "TerraFailLB_cognito_user_pool" {
  name = "TerraFailLB_cognito_user_pool"
}

resource "aws_cognito_user_pool_client" "TerraFailLB_cognito_user_pool_client" {
  name         = "TerraFailLB_cognito_user_pool_client"
  user_pool_id = aws_cognito_user_pool.TerraFailLB_cognito_user_pool.id
}

resource "aws_cognito_user_pool_domain" "TerraFailLB_cognito_user_pool_domain" {
  domain       = "TerraFailLB_cognito_user_pool_domain"
  user_pool_id = aws_cognito_user_pool.TerraFailLB_cognito_user_pool.id
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
