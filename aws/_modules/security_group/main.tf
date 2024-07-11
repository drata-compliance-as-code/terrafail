

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "aws_vpc" "TerraFailSecurityGroup_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_security_group" "TerraFailSecurityGroup" {
  name                   = "TerraFailSecurityGroup"
  description            = "Allow TLS inbound traffic"
  vpc_id                 = aws_vpc.TerraFailSecurityGroup_vpc.id
  revoke_rules_on_delete = false

  tags = {
    name = "TerraFailSecurityGroup"
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["129.0.1.0/32"]
    ipv6_cidr_blocks = ["::/1"]
  }

  egress {
    from_port        = 80
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["129.0.1.0/32"]
    ipv6_cidr_blocks = ["::/1"]
  }
}
