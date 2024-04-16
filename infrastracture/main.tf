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
  etag = filemd5("../docker-compose.yml")
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file(var.ssh-public-key)
}

module "security" {
  source = "./modules/security"
  vpc_id = module.networking.vpc_id
}

module "networking" {
  source     = "./modules/networking"
  cidr_block = "10.0.0.0/16"
}

module "elastic_beanstalk" {
  source = "./modules/elastic_beanstalk"
  count = var.beanstalk_deployment ? 1 : 0
  application_name            = "tic-tac-toe-app"
  description                 = "Tic Tac Toe application"
  solution_stack_name         = "64bit Amazon Linux 2023 v4.3.0 running Docker"
  version_label               = "1.0.0"
  bucket                      = aws_s3_bucket.my-ttt-bucket.bucket
  key                         = aws_s3_object.my-s3-object.key
  instance_profile            = aws_iam_instance_profile.elastic_beanstalk_ec2_profile.name
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.deployer.key_name
  associate_public_ip_address = true
  vpc_id                      = module.networking.vpc_id
  subnet_ids                  = [module.networking.subnet_id]
  security_group_ids          = [module.security.security_group_id]
}