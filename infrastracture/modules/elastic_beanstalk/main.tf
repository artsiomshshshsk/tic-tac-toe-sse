resource "aws_elastic_beanstalk_application" "app" {
  name        = var.application_name
  description = var.description
}

resource "aws_elastic_beanstalk_application_version" "version" {
  name        = var.version_label
  application = aws_elastic_beanstalk_application.app.name
  description = "Version ${var.version_label} of ${var.application_name}"
  bucket      = var.bucket
  key         = var.key
}

resource "aws_elastic_beanstalk_environment" "env" {
  name                = "${var.application_name}-env"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = var.solution_stack_name
  version_label       = aws_elastic_beanstalk_application_version.version.name

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = var.instance_profile
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = var.instance_type
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = var.key_name
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = tostring(var.associate_public_ip_address)
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.vpc_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", var.subnet_ids)
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = join(",", var.security_group_ids)
  }
}