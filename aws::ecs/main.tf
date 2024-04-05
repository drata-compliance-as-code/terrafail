

# ---------------------------------------------------------------------
# ECS
# ---------------------------------------------------------------------
resource "aws_ecs_cluster" "sac_ecs_cluster" {
  name = "sac-testing-ecs-cluster"
  # setting { # SaC Testing - Severity: Low - set setting to undefined
  #     name  = "containerInsights"
  #     value = "enabled"
  # }
  # SaC Testing - Severity: Moderate -
  # tags = { set tags to undefined
  #     Name = "test-app"
  # }
}

resource "aws_ecs_service" "sac_ecs_service" {
  name            = "sac-testing-ecs-service"
  cluster         = aws_ecs_cluster.sac_ecs_cluster.arn
  task_definition = aws_ecs_task_definition.sac_ecs_task_definition.arn
  launch_type     = "EC2"
  # network_configuration {
  #   subnets          = [aws_subnet.sac_ecs_subnet.id]
  #   assign_public_ip = false   # default = false
  #   security_groups  = [aws_security_group.sac_ecs_security_group.id] # SaC Testing - Severity: Critical - Set security_groups to []
  # }
  # SaC Testing - Severity: Moderate - set tags to undefined
  # tags = {
  #     Environment="dev"
  #   }
}

resource "aws_ecs_task_definition" "sac_ecs_task_definition" {
  family = "sac-ecs-task-def"
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
  network_mode = "awsvpc"
  volume {
    name = "myEfsVolume"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.sac_ecs_efs.id
      transit_encryption = "DISABLED" # SaC Testing - Severity: Critical - Set transit_encryption to disabled

      authorization_config {
        iam = "DISABLED"
      }
    }
  }
  # SaC Testing - Severity: Moderate - Set tags to undefined
  # tags = {
  #     Environment="dev"
  #   }
}
