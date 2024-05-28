# ---------------------------------------------------------------------
# VPC
# ---------------------------------------------------------------------
resource "aws_vpc" "TerraFailVPC" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_vpc" "TerraFailVPC_peer" {
  cidr_block = "10.2.0.0/16"

  tags = {
    Name = "TerraFailVPC_peer"
  }
}

resource "aws_vpc_peering_connection" "TerraFailVPC_peering_connection" {
  vpc_id      = aws_vpc.TerraFailVPC.id
  peer_vpc_id = aws_vpc.TerraFailVPC_peer.id
}
