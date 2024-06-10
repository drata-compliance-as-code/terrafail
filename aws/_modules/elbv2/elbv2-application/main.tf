
# ---------------------------------------------------------------------
# ELBv2
# ---------------------------------------------------------------------
resource "aws_lb" "TerraFailLB" {
  # Drata: Set [aws_lb.tags] to ensure that organization-wide tagging conventions are followed.
  # Drata: Default network security groups allow broader access than required. Specify [aws_lb.security_groups] to configure more granular access control
  name                       = "TerraFailLB"
  load_balancer_type         = "application"
  drop_invalid_header_fields = true
  desync_mitigation_mode     = "monitor"
  internal                   = true

  subnet_mapping {
    subnet_id = aws_subnet.TerraFailLB_subnet.id
  }
  subnet_mapping {
    subnet_id = aws_subnet.TerraFailLB_subnet_2.id
  }
  access_logs {
    bucket  = aws_s3_bucket.TerraFailLB_bucket.bucket
    enabled = false
  }
}

resource "aws_lb_target_group" "TerraFailLB_target_group" {
  name        = "TerraFailLB_target_group"
  target_type = "instance"
  vpc_id      = aws_vpc.TerraFailLB_vpc.id
  port        = 80
  protocol    = "HTTP"

  health_check {
    enabled  = true
    protocol = "HTTP"
  }

  stickiness {
    enabled = false
    type    = "lb_cookie"
  }
}

resource "aws_lb_listener_rule" "TerraFailLB_listener_rule" {
  listener_arn = aws_lb_listener.TerraFailLB_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TerraFailLB_target_group.arn

    authenticate_cognito {
      on_unauthenticated_request = "allow"
      session_cookie_name        = ""
      session_timeout            = 3600
      user_pool_arn              = aws_cognito_user_pool.TerraFailLB_cognito_user_pool.arn
      user_pool_client_id        = aws_cognito_user_pool_client.TerraFailLB_cognito_user_pool_client.id
      user_pool_domain           = aws_cognito_user_pool_domain.TerraFailLB_cognito_user_pool_domain.domain
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
  port              = 99
  protocol          = "HTTPS"

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
      session_timeout            = 100000
    }
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
  # Drata: Set [aws_vpc.tags] to ensure that organization-wide tagging conventions are followed.
  cidr_block = "10.0.0.0/16"
}

resource "aws_security_group" "TerraFailLB_security_group" {
  # Drata: Set [aws_security_group.tags] to ensure that organization-wide tagging conventions are followed.
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
  # Drata: Ensure that [aws_security_group.egress.cidr_blocks] is explicitly defined and narrowly scoped to only allow traffic to trusted sources
  }
}

# ---------------------------------------------------------------------
# S3
# ---------------------------------------------------------------------
resource "aws_s3_bucket" "TerraFailLB_bucket" {
  # Drata: Set [aws_s3_bucket.tags] to ensure that organization-wide tagging conventions are followed.
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
  availability_zone           = "us-east-2b"
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
      "name" = "TerraFailLB_instance"
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
    "name" = "TerraFailLB_launch_template"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }
}

# ---------------------------------------------------------------------
# KMS
# ---------------------------------------------------------------------
resource "aws_kms_key" "TerraFailLB_key" {
  # Drata: Define [aws_kms_key.policy] to restrict access to your resource. Follow the principal of minimum necessary access, ensuring permissions are scoped to trusted entities. Exclude this finding if access to Keys is managed using IAM policies instead of a Key policy
  # Drata: Set [aws_kms_key.tags] to ensure that organization-wide tagging conventions are followed.
  description             = "TerraFailLB_key"
  deletion_window_in_days = 10
}

# ---------------------------------------------------------------------
# IAM
# ---------------------------------------------------------------------
resource "aws_iam_instance_profile" "TerraFailLB_instance_profile" {
  name = "TerraFailLB_instance_profile"
  role = aws_iam_role.TerraFailLB_role.name
}

resource "aws_iam_role" "TerraFailLB_role" {
  # Drata: Set [aws_iam_role.tags] to ensure that organization-wide tagging conventions are followed.
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
