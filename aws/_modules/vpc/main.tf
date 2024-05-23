# ---------------------------------------------------------------------
# VPC
# ---------------------------------------------------------------------
resource "aws_vpc" "sac_vpc" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_vpc" "sac_peer_vpc" {
  cidr_block = "10.2.0.0/16"

  tags = {
    Name = "Default VPC"
  }
}

resource "aws_vpc_peering_connection" "sac_vpc_pc" {
  vpc_id        = aws_vpc.sac_vpc.id
  peer_vpc_id = aws_vpc.sac_peer_vpc.id
}