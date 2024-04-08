
# ---------------------------------------------------------------------
# ELBv2
# ---------------------------------------------------------------------
resource "aws_lb" "elbv2_sac" {
  name                       = "elbv2-sac"
  load_balancer_type         = "application"
  drop_invalid_header_fields = true      # SaC Testing - Severity:  - Set drop_invalid_header_fields to true
  desync_mitigation_mode     = "monitor" # SaC Testing - Severity:  - Set desync_mitigation_mode != ['defensive', 'strictest']
  internal                   = true
  enable_deletion_protection = false     # SaC Testing - Severity: Moderate - Set enable_deletion_protection to undefined
  #security_groups = [aws_security_group.ec2_instance_security_group_default.id]  # SaC Testing - Severity: Moderate - Set security_groups to undefined
  # SaC Testing - Severity: Moderate - Set tags to undefined
  # tags = {
  #   key = "value"
  # }
  subnet_mapping {
    subnet_id = aws_subnet.elbv2_subnet_1.id
  }
  # subnet_mapping {  # SaC Testing - Severity: Moderate - Set subnets < 2
  #   subnet_id = aws_subnet.elbv2_subnet_2.id
  # }
  access_logs {
    bucket  = aws_s3_bucket.elbv2_bucket.bucket
    enabled = false # SaC Testing - Severity: High - Set enabled to false
  }
}

resource "aws_lb_target_group" "elbv2_target_group" {
  name        = "elbv2-target-group-sac"
  target_type = "instance"
  vpc_id      = aws_vpc.ec2_instance_vpc_default.id
  port        = 80
  protocol    = "HTTP" # SaC Testing - Severity: Critical - Set protocol != ['https', 'tls']
  health_check {
    enabled  = true   # SaC Testing - Severity: Moderate - Set enabled to false
    protocol = "HTTP" # SaC Testing - Severity: Critical - Set protocol != ['https', 'tls']
  }
  stickiness {
    enabled = false       # SaC Testing - Severity:  - Set enabled to false
    type    = "lb_cookie" # SaC Testing - Severity:  - Set type to ""
  }
}

resource "aws_lb_listener_rule" "elbv2-listener-rule" {
  listener_arn = aws_lb_listener.elbv2_listener.arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.elbv2_target_group.arn # SaC Testing - Severity:  - Set target_group_arn to undefined
    authenticate_cognito {
      on_unauthenticated_request = "allow" # SaC Testing - Severity: Moderate - Set on_unauthenticated_request != ['authenticate' 'deny']
      session_cookie_name        = ""      # SaC Testing - Severity:  - Set session_cookie_name to ""
      session_timeout            = 3600    # SaC Testing - Severity:  - Set session_timeout < 3600
      user_pool_arn              = aws_cognito_user_pool.elbv2_user_pool.arn
      user_pool_client_id        = aws_cognito_user_pool_client.elbv2_user_pool_client.id
      user_pool_domain           = aws_cognito_user_pool_domain.elbv2_user_pool_domain.domain
    }
  }
  condition {
    host_header {
      values = ["example.com"]
    }
  }
}

resource "aws_lb_listener" "elbv2_listener" {
  load_balancer_arn = aws_lb.elbv2_sac.arn
  port              = 99
  protocol          = "HTTP" # SaC Testing - Severity: Critical - Set protocol != ['https', 'tls']
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.elbv2_target_group.arn
    authenticate_cognito {
      user_pool_arn       = aws_cognito_user_pool.elbv2_user_pool.arn
      user_pool_client_id = aws_cognito_user_pool_client.elbv2_user_pool_client.id
      user_pool_domain    = aws_cognito_user_pool_domain.elbv2_user_pool_domain.domain
      authentication_request_extra_params = {
        key = "value"
      }
      on_unauthenticated_request = "allow" # SaC Testing - Severity: Moderate - Set on_unauthenticated_request != ['authenticate' 'deny']
      #session_cookie_name = "elbv2-listener-cookie"  # SaC Testing - Severity:  - Set session_cookie_name to ""
      session_timeout = 100000 # SaC Testing - Severity:  - Set session_timeout > 86400
    }
  }
}

resource "aws_lb_target_group_attachment" "elbv2_target_group_attachment" {
  target_group_arn = aws_lb_target_group.elbv2_target_group.arn
  target_id        = aws_instance.aws_ec2_instance_sac_default.id
  #port = 99  # SaC Testing - Severity:  - Set port to undefined
}
