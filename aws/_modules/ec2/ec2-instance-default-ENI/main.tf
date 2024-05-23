

# ---------------------------------------------------------------------
# EC2-Instance
# ---------------------------------------------------------------------
resource "aws_instance" "aws_ec2_instance_sac_default" {
  ami       = data.aws_ami.ubuntu.id
  subnet_id = aws_subnet.ec2_instance_subnet_default.id

  launch_template {
    id = aws_launch_template.aws_ec2_launch_template_sac_default.id
  }

  associate_public_ip_address = true
  monitoring                  = false

  ebs_block_device {
    delete_on_termination = false
    device_name           = "/dev/sdf"
    encrypted             = false
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
# Network
# ---------------------------------------------------------------------
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
