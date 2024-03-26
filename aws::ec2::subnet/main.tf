# ---------------------------------------------------------------------
# Subnet
# ---------------------------------------------------------------------
resource "aws_subnet" "sac_subnet" {
  vpc_id     = aws_vpc.apigwv2_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-2c"

  map_public_ip_on_launch = true    # SaC Testing - Severity: Moderate - map_public_ip_on_launch to True
  # tags = {  # SaC Testing - Severity: Moderate - tags to undefined
  #   Name = "apigwv2_subnet"
  # }
}