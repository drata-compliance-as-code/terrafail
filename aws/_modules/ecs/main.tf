

# ---------------------------------------------------------------------
# ECS
# ---------------------------------------------------------------------
resource "aws_ecs_cluster" "TerraFailECS_cluster" {
  name = "TerraFailECS_cluster"
}

resource "aws_ecs_service" "TerraFailECS_service" {
  name            = "TerraFailECS_service"
  cluster         = aws_ecs_cluster.TerraFailECS_cluster.arn
  task_definition = aws_ecs_task_definition.TerraFailECS_task_definition.arn
  launch_type     = "EC2"
}

resource "aws_ecs_task_definition" "TerraFailECS_task_definition" {

  family = "TerraFailECS_task_definition"
  container_definitions = jsonencode([{
    "memory" : 32,
    "essential" : true,
    "entryPoint" : [
      "ping"
    ],
    "name" : "alpine_ping",
    "readonlyRootFilesystem" : true,
    "image" : "alpine:3.4",
    "command" : [
      "-c",
      "4",
      "google.com"
    ],
    "cpu" : 16
  }])

  cpu          = 1024
  memory       = 2048
  network_mode = "none"

  volume {
    name = "myEfsVolume"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.TerraFailECS_efs.id
      transit_encryption = "DISABLED"

      authorization_config {
        iam = "DISABLED"
      }
    }
  }
}

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "aws_subnet" "TerraFailECS_subnet" {
  vpc_id     = aws_vpc.TerraFailECS_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Main"
  }
}

resource "aws_vpc" "TerraFailECS_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_security_group" "TerraFailECS_security_group" {
  name                   = "TerraFailECS_security_group"
  description            = "Allow TLS inbound traffic"
  vpc_id                 = aws_vpc.TerraFailECS_vpc.id
  revoke_rules_on_delete = false

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["127.0.1.0/32"]
    ipv6_cidr_blocks = ["::/1"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["127.0.1.0/32"]
  }
}

# ---------------------------------------------------------------------
# EFS
# ---------------------------------------------------------------------
resource "aws_efs_file_system" "TerraFailECS_efs" {
  creation_token = "efs-html"

  tags = {
    Environment = "dev"
  }
}
