

# ---------------------------------------------------------------------
# ElasticBeanstalk
# ---------------------------------------------------------------------
resource "aws_elastic_beanstalk_application" "sac_beanstalk_application" {
  name = "sac-testing-beanstalk-app"
  appversion_lifecycle {
    service_role = "arn:aws:iam::709695003849:role/aws-elasticbeanstalk-service-role"
    max_count    = 128
  }
}

resource "aws_elastic_beanstalk_environment" "sac_beanstalk_environment" {
  name                = "sac-testing-beanstalk-env"
  application         = aws_elastic_beanstalk_application.sac_beanstalk_application.name
  solution_stack_name = "64bit Amazon Linux 2015.03 v2.0.3 running Go 1.4"
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "aws-elasticbeanstalk-ec2-role"
  }
  # SaC Testing - Severity: Moderate - set automatic updates to disabled
  # setting {
  #   namespace = "aws:elasticbeanstalk:managedactions"
  #   name = "ManagedActionsEnabled"
  #   value = "true"
  # }
  # setting {
  #   namespace = "aws:elasticbeanstalk:managedactions"
  #   name = "PreferredStartTime"
  #   value = "Tue:09:00"
  # }
  # setting {
  #   namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
  #   name = "UpdateLevel"
  #   value = "minor"
  # }

  # SaC Testing - Severity: Moderate - set tags to undefined
  # tags = {
  #   key = "value"
  # }
}
