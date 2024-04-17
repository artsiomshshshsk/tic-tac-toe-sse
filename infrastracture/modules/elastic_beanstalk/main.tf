resource "aws_iam_instance_profile" "elastic_beanstalk_ec2_profile" {
  name = "elastic_beanstalk_ec2_profile"
  role = "LabRole"
}

resource "aws_s3_bucket" "my-ttt-bucket" {
  bucket = "my-artsi-tic-tac-toe-bucket"
}

resource "aws_s3_object" "my-s3-object" {
  bucket = aws_s3_bucket.my-ttt-bucket.id
  key    = "docker-compose.yml"
  source = "../docker-compose.yml"
  etag   = filemd5("../docker-compose.yml")
}

resource "aws_elastic_beanstalk_application" "app" {
  name        = var.application_name
  description = var.description
}

resource "aws_elastic_beanstalk_application_version" "version" {
  name        = var.version_label
  application = aws_elastic_beanstalk_application.app.name
  description = "Version ${var.version_label} of ${var.application_name}"
  bucket      = aws_s3_bucket.my-ttt-bucket.bucket
  key         = aws_s3_object.my-s3-object.key
}

resource "aws_elastic_beanstalk_environment" "env" {
  name                = "${var.application_name}-env"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = var.solution_stack_name
  version_label       = aws_elastic_beanstalk_application_version.version.name

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.elastic_beanstalk_ec2_profile.name
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
    value     = true
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