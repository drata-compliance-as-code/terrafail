

# ---------------------------------------------------------------------
# ELBv1
# ---------------------------------------------------------------------
resource "aws_elb" "TerraFailELB" {
  name     = "TerraFailELB"
  subnets  = [aws_subnet.TerraFailELB_subnet.id]
  internal = true

  listener {
    instance_port     = 8000
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
}

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "aws_security_group" "TerraFailELB_security_group" {
  name                   = "TerraFailELB_security_group"
  description            = "Allow TLS inbound traffic"
  vpc_id                 = aws_vpc.TerraFailELB_vpc.id
  revoke_rules_on_delete = false

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_subnet" "TerraFailELB_subnet" {
  vpc_id            = aws_vpc.TerraFailELB_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "TerraFailELB_subnet"
  }
}

resource "aws_vpc" "TerraFailELB_vpc" {
  cidr_block = "10.0.0.0/16"
}
