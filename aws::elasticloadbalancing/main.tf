

# ---------------------------------------------------------------------
# ELBv1
# ---------------------------------------------------------------------
resource "aws_elb" "sac_elbv1" {
  name = "sac-elbv1"
  # availability_zones = ["us-east-2b"] # SaC Testing - Severity: Moderate - Set availability zones to undefined
  subnets = [aws_subnet.elbv1_subnet1.id] # SaC Testing - Severity: Moderate - Set subnets to < 2
  # security_groups = [ aws_security_group.elbv1_security_group.id ]  # SaC Testing - Severity: Moderate - Set security groups to undefined
  internal = true
  access_logs { # SaC Testing - Severity: High - Set access_logs to undefined or enabled = false
    bucket        = aws_s3_bucket.s3_access_logs_bucket.bucket
    enabled = false
  }
  listener {
    instance_port     = 8000
    instance_protocol = "HTTP" # SaC Testing - Severity: Critical - Set instance protocol to HTTP
    lb_port           = 80
    lb_protocol       = "HTTP" # SaC Testing - Severity: Critical - Set listener protocol to HTTP
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  # SaC Testing - Severity: Moderate - Set tags to undefined
  # tags = {
  #   Name = "sac-test-elbv1"
  # }
}

resource "aws_load_balancer_policy" "elbv1-listener-policy" {
  load_balancer_name = aws_elb.sac_elbv1.name
  policy_name        = "elbv1-ssl-policy"
  policy_type_name   = "SSLNegotiationPolicyType"

  policy_attribute {
    name  = "Reference-Security-Policy"
    value = "ELBSecurityPolicy-TLS-1-1-2017-01" # SaC Testing - Severity: Critical - Set valye != predefined TLS policy
  }
}
