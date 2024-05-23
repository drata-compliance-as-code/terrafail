
# ---------------------------------------------------------------------
# Network ACL
# ---------------------------------------------------------------------
resource "aws_network_acl" "sac_network_acl" {
  vpc_id = aws_vpc.sac_vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
}

# ---------------------------------------------------------------------
# VPC
# ---------------------------------------------------------------------
resource "aws_vpc" "sac_vpc" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "Default VPC"
  }
}
