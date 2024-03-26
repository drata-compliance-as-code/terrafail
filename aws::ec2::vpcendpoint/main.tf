# ---------------------------------------------------------------------
# VPC
# ---------------------------------------------------------------------
resource "aws_vpc" "sac_vpc" {
  cidr_block = "10.1.0.0/16"
  # SaC Testing - Severity: Moderate - Set tags to undefined
  # tags = {
  #   Name = "Default VPC"
  # }
}

resource "aws_vpc_peering_connection" "sac_vpc_pc" {
  vpc_id      = aws_vpc.sac_vpc.id
  peer_vpc_id = aws_vpc.sac_peer_vpc.id
  # SaC Testing - Severity: Moderate - Set tags to undefined
  # tags = {
  #   Name = "Default VPC"
  # }
}
