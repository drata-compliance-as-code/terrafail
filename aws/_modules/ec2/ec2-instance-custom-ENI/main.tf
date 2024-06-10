

# ---------------------------------------------------------------------
# EC2-Instance
# ---------------------------------------------------------------------
resource "aws_instance" "TerraFailEC2Instance" {
  ami = data.aws_ami.ubuntu.id

  launch_template {
    id = aws_launch_template.TerraFailEC2Instance_launch_template.id
  }

  monitoring = false
  network_interface {
    network_interface_id  = aws_network_interface.TerraFailEC2Instance_network_interface.id
    delete_on_termination = false
    device_index          = 0
  }

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

resource "aws_launch_template" "TerraFailEC2Instance_launch_template" {
  name                                 = "TerraFailEC2Instance_launch_template"
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
resource "aws_network_interface" "TerraFailEC2Instance_network_interface" {
  subnet_id       = aws_subnet.TerraFailEC2Instance_subnet.id
  security_groups = [aws_security_group.TerraFailEC2Instance_security_group.id]
}

resource "aws_subnet" "TerraFailEC2Instance_subnet" {
  vpc_id     = aws_vpc.TerraFailEC2Instance_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Main"
  }
}

resource "aws_vpc" "TerraFailEC2Instance_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_security_group" "TerraFailEC2Instance_security_group" {
  name                   = "TerraFailEC2Instance_security_group"
  description            = "Allow TLS inbound traffic"
  vpc_id                 = aws_vpc.TerraFailEC2Instance_vpc.id
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
