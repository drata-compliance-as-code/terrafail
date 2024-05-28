

# ---------------------------------------------------------------------
# ElasticBeanstalk
# ---------------------------------------------------------------------
resource "aws_elastic_beanstalk_application" "TerraFailElasticBeanstalk" {
  name = "TerraFailElasticBeanstalk"

  appversion_lifecycle {
    service_role = "arn:aws:iam::709695003849:role/aws-elasticbeanstalk-service-role"
    max_count    = 128
  }
}

resource "aws_elastic_beanstalk_environment" "TerraFailElasticBeanstalk_environment" {
  name                = "TerraFailElasticBeanstalk_environment"
  application         = aws_elastic_beanstalk_application.TerraFailElasticBeanstalk.name
  solution_stack_name = "64bit Amazon Linux 2015.03 v2.0.3 running Go 1.4"
}
