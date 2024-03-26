
# ---------------------------------------------------------------------
# Network ACL
# ---------------------------------------------------------------------
resource "aws_network_acl" "sac_network_acl" {
  vpc_id = aws_vpc.sac_vpc.id
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0" # SaC Testing - Severity: High - Set cidr_block to '*' '0.0.0.0/0'
    from_port  = 443
    to_port    = 443
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0" # SaC Testing - Severity: High - Set cidr_block to '*' '0.0.0.0/0
    from_port  = 80
    to_port    = 80
  }
  # SaC Testing - Severity: Moderate - Set tags to undefined
  # tags = {
  #   Name = "main"
  # }
}
