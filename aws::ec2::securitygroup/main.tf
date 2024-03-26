

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "aws_security_group" "sac_security_group" {
  name                   = "sac-security-group"
  description            = "Allow TLS inbound traffic"
  vpc_id                 = aws_vpc.security_group_vpc.id
  revoke_rules_on_delete = false
  
  # ingress { # SaC Testing - Severity: Low - Set ingress to undefined
  #   description      = "TLS from VPC"
  #   from_port        = 80
  #   to_port          = 443
  #   protocol         = "tcp"         # SaC Testing - Severity: Low - Set protocol to -1
  #   cidr_blocks      = ["0.0.0.0/0"] # SaC Testing - Severity: Low - Set cidr_blocks to undefined
  #   ipv6_cidr_blocks = ["::/0"]      # SaC Testing - Severity: Low - Set ipv6_cidr_blocks to undefined
  # }
  ingress { # SaC Testing - Severity: Low - Set ingress to undefined
    description      = "SSH"
    from_port        = 3
    to_port          = 4
    protocol         = "tcp"         # SaC Testing - Severity: Low - Set protocol to -1
    cidr_blocks      = ["0.0.0.0/0"] # SaC Testing - Severity: Low - Set cidr_blocks to undefined
    ipv6_cidr_blocks = ["::/0"]      # SaC Testing - Severity: Low - Set ipv6_cidr_blocks to undefined
  }
  # egress { # SaC Testing - Severity: Low - Set egress to undefined
  #   from_port        = 80
  #   to_port          = 443
  #   protocol         = "tcp"         # SaC Testing - Severity: Low - Set protocol to -1
  #   cidr_blocks      = ["0.0.0.0/0"] # SaC Testing - Severity: Low - Set cidr_blocks to undefined
  #   ipv6_cidr_blocks = ["::/0"]      # SaC Testing - Severity: Low - Set ipv6_cidr_blocks to undefined
  # }
  egress {
    description      = "SSH"
    from_port        = 4
    to_port          = 4
    protocol         = "tcp"         # SaC Testing - Severity: Low - Set protocol to -1
    cidr_blocks      = ["0.0.0.0/0"] # SaC Testing - Severity: Low - Set cidr_blocks to undefined
    ipv6_cidr_blocks = ["::/0"]      # SaC Testing - Severity: Low - Set ipv6_cidr_blocks to undefined
  }
  # SaC Testing - Severity: Low - Set tags to undefined
  # tags = {
  #   key = "value"
  # }
}
