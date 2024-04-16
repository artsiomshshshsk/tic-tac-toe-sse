terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}


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
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file(var.ssh-public-key)
}

resource "aws_elastic_beanstalk_application" "ttt-app" {
  name        = "tic-tac-toe-app"
  description = "Tic Tac Toe application"
}

resource "aws_elastic_beanstalk_application_version" "ttt-app-version" {
  name        = "1.0.0"
  application = aws_elastic_beanstalk_application.ttt-app.name
  description = "Tic Tac Toe application version"
  bucket      = aws_s3_bucket.my-ttt-bucket.bucket
  key         = aws_s3_object.my-s3-object.key
}

resource "aws_elastic_beanstalk_environment" "ttt-env" {
  name                = "tic-tac-toe-end"
  application         = aws_elastic_beanstalk_application.ttt-app.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.3.0 running Docker"
  version_label       = aws_elastic_beanstalk_application_version.ttt-app-version.name

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.elastic_beanstalk_ec2_profile.name
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t2.micro"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = aws_key_pair.deployer.key_name
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "true"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_vpc.app_vpc.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = aws_subnet.app_subnet.id
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.app_sg.id
  }
}


resource "aws_security_group" "app_sg" {
  name        = "tic_tac_toe_sg"
  description = "Allow traffic for Tic-Tac-Toe app"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    description = "Frontend"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "DNS (UDP)"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "DNS (TCP)"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_vpc" "app_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "app_subnet" {
  vpc_id     = aws_vpc.app_vpc.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_internet_gateway" "app_gw" {
  vpc_id = aws_vpc.app_vpc.id
}

resource "aws_route_table" "app_rt" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.app_subnet.id
  route_table_id = aws_route_table.app_rt.id
}