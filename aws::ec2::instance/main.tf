

# ---------------------------------------------------------------------
# EC2-Instance
# ---------------------------------------------------------------------
resource "aws_instance" "aws_ec2_instance_sac" {
  ami = data.aws_ami.ubuntu.id

  launch_template {
    id = aws_launch_template.aws_ec2_launch_template_sac.id
  }
  #availability_zone = "us-east-2c" # SaC Testing - Severity: Low - Set availability_zone to undefined
  #iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name  # SaC Testing - Severity: Critical - Set iam_instance_profile to "" 
  monitoring = false #SaC Testing - Severity: Moderate - Set monitoring to false
  # SaC Testing - Severity: Moderate - Set tags to undefined
  # tags = {
  #   "key" = "value"
  # }
  network_interface { #SaC Testing - Severity: Critical - Set network_interface to undefined
    network_interface_id  = aws_network_interface.ec2_instance_network_interface.id
    delete_on_termination = false
    device_index          = 0
  }
  ebs_block_device {
    delete_on_termination = false
    device_name           = "/dev/sdf"
    encrypted             = false # SaC Testing - Severity: Critical - Set ebs_block_device.encrypted to false
    #kms_key_id = ""  # SaC Testing - Severity: High - Set ebs_block_device.kms_key_id to ""
    volume_size = 5
    tags = {
      "key" = "value"
    }
  }
}
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

resource "aws_launch_template" "aws_ec2_launch_template_sac" {
  name                                 = "ec2-instance-launch-template-sac"
  default_version                      = 1
  disable_api_stop                     = false
  disable_api_termination              = false
  ebs_optimized                        = true
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = "t2.micro"
  tags = {
    "key" = "value"
  }
  network_interfaces {
    associate_public_ip_address = false
  }
  metadata_options {
    http_endpoint               = "optional"
    http_tokens                 = "optional" # SaC Testing - Severity: Low - Set http_tokens to 'optional'
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }
}
