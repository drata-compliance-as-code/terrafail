
# ---------------------------------------------------------------------
# Network ACL
# ---------------------------------------------------------------------
resource "aws_network_acl" "sac_network_acl" {
  vpc_id = aws_vpc.sac_vpc.id
  # SaC Testing - Severity: Moderate - Set tags to undefined
  # tags = {
  #   Name = "main"
  # }
}

resource "aws_network_acl_rule" "sac_network_acl_ingress" {
  network_acl_id = aws_network_acl.sac_network_acl.id
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}
resource "aws_network_acl_rule" "sac_network_acl_egress" {
  network_acl_id = aws_network_acl.sac_network_acl.id
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}
