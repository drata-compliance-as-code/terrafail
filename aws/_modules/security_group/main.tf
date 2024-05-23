

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "aws_vpc" "security_group_vpc" {
  cidr_block = "10.0.0.0/16" 
}

resource "aws_security_group" "sac_security_group" {
  name                   = "sac-security-group"
  description            = "Allow TLS inbound traffic"
  vpc_id                 = aws_vpc.security_group_vpc.id
  revoke_rules_on_delete = false

  tags = {
    key = "value"
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port       = 80
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}