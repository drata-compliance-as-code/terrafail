

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "aws_vpc" "TerraFailSecurityGroup_vpc" {
  # Drata: Set [aws_vpc.tags] to ensure that organization-wide tagging conventions are followed.
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
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 80
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    # Drata: Ensure that [aws_security_group.ingress.cidr_blocks] is explicitly defined and narrowly scoped to only allow traffic from trusted sources
    # Drata: Ensure that [aws_security_group.egress.cidr_blocks] is explicitly defined and narrowly scoped to only allow traffic to trusted sources
    ipv6_cidr_blocks = ["::/0"]
  }
}
