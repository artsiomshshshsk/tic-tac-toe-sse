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
  source              = "./modules/elastic_beanstalk"
  count               = var.beanstalk_deployment ? 1 : 0
  application_name    = "tic-tac-toe-app"
  description         = "Tic Tac Toe application"
  solution_stack_name = "64bit Amazon Linux 2023 v4.3.0 running Docker"
  version_label       = "1.0.0"
  instance_type       = "t2.micro"
  key_name            = aws_key_pair.deployer.key_name
  vpc_id              = module.networking.vpc_id
  subnet_ids          = [module.networking.subnet_ids[0]]
  security_group_ids  = [module.security.security_group_id]
}


resource "aws_s3_bucket" "avatar_bucket" {
  bucket = "tic-tac-toe-bucket-34cb38ee-927a-4f5f-a5e0-bd5bfabe6fd6"

  tags = {
    Name = "Avatar Bucket"
  }
}

// {
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//      "Sid": "PublicReadGetObject",
//      "Effect": "Allow",
//      "Principal": "*",
//      "Action": "s3:GetObject",
//      "Resource": "arn:aws:s3:::tic-tac-toe-bucket-34cb38ee-927a-4f5f-a5e0-bd5bfabe6fd6/*"
//    }
//  ]
//}


resource "aws_s3_object" "user1_avatar" {
  bucket = aws_s3_bucket.avatar_bucket.id
  key    = "user1-avatar.jpeg"
  source = "./avatar1.jpeg"
  etag   = filemd5("./avatar1.jpeg")
}

resource "aws_s3_object" "user2_avatar" {
  bucket = aws_s3_bucket.avatar_bucket.id
  key    = "user2-avatar.jpeg"
  source = "./avatar2.jpeg"
  etag   = filemd5("./avatar2.jpeg")
}


module "ec2" {
  source                      = "./modules/ec2_instance"
  count                       = var.ec2_deployment ? 1 : 0
  ami                         = var.ec2-ami
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.deployer.key_name
  security_group_id           = module.security.security_group_id
  subnet_ids                  = module.networking.subnet_ids
  cognito_user_pool_client_id = module.cognito.client_id
  cognito_user_pool_id        = module.cognito.user_pool_id
  cognito_user_pool_region    = var.region
  vpc_id                      = module.networking.vpc_id
  rds_endpoint                = aws_db_instance.postgres.endpoint
  profile_image_url_1         = "https://${aws_s3_bucket.avatar_bucket.bucket}.s3.amazonaws.com/${aws_s3_object.user1_avatar.key}"
  profile_image_url_2         = "https://${aws_s3_bucket.avatar_bucket.bucket}.s3.amazonaws.com/${aws_s3_object.user2_avatar.key}"
}


module "fargate" {
  count                       = var.fargate_deployment ? 1 : 0
  source                      = "./modules/fargate"
  cluster_name                = "tic-tac-toe-cluster"
  cpu                         = "256"
  memory                      = "512"
  desired_count               = 1
  subnets                     = [module.networking.subnet_ids[0]]
  security_groups             = [module.security.security_group_id]
  assign_public_ip            = true
  cognito_user_pool_client_id = module.cognito.client_id
  cognito_user_pool_id        = module.cognito.user_pool_id
  cognito_user_pool_region    = var.region
}

module "cognito" {
  source                = "./modules/cognito"
  user_pool_client_name = "tic-tac-toe-user-pool-client-artsi"
  user_pool_name        = "tic-tac-toe-user-pool-artsi"
  user_pool_domain_name = "ttt-user-pool-artsi"
}


resource "aws_security_group" "db-sg" {
  vpc_id = module.networking.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
#    security_groups = [module.security.security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "main-sg"
  }
}


resource "aws_db_instance" "postgres" {
  allocated_storage      = 20
  engine                 = "postgres"
  publicly_accessible    = true
  engine_version         = "16.3"
  instance_class         = "db.t3.micro"
  username               = "artsi"
  password               = "artsiartsi"
  parameter_group_name   = "default.postgres16"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.db-sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  db_name                = "tictactoedb"

  tags = {
    Name = "postgres-rds"
  }
}


resource "aws_db_subnet_group" "main" {
  name       = "main-subnet-group"
  subnet_ids = module.networking.subnet_ids

  tags = {
    Name = "main-subnet-group"
  }
}

