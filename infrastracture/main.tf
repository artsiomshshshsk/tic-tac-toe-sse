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

module "networking" {
  source     = "./modules/networking"
  cidr_block = "10.0.0.0/16"
}

module "cognito" {
  source                = "./modules/cognito"
  user_pool_client_name = "tic-tac-toe-user-pool-client-artsi"
  user_pool_name        = "tic-tac-toe-user-pool-artsi"
  user_pool_domain_name = "ttt-user-pool-artsi"
}


resource "aws_security_group" "app_sg" {
  name        = "tic_tac_toe_sg"
  description = "Allow traffic for Tic-Tac-Toe app"
  vpc_id      = module.networking.vpc_id

  ingress {
    description = "Frontend"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Load balancer"
    from_port   = 80
    to_port     = 80
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

  //postgres
  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "avatar_bucket" {
  bucket = "tic-tac-toe-bucket-34cb38ee-927a-4f5f-a5e0-bd5bfabe6fd6"

  tags = {
    Name = "Avatar Bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "avatar_bucket" {
  bucket = aws_s3_bucket.avatar_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

//policy for public-read
resource "aws_s3_bucket_policy" "avatar_bucket" {
  bucket = aws_s3_bucket.avatar_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.avatar_bucket.arn}/*",
      },
    ],
  })
}


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
  security_group_id           = aws_security_group.app_sg.id
  subnet_ids                  = [module.networking.app_subnet.id]
  cognito_user_pool_client_id = module.cognito.client_id
  cognito_user_pool_id        = module.cognito.user_pool_id
  cognito_user_pool_region    = var.region
  vpc_id                      = module.networking.vpc_id
  rds_endpoint                = aws_db_instance.postgres.endpoint
  profile_image_url_1         = "https://${aws_s3_bucket.avatar_bucket.bucket}.s3.amazonaws.com/${aws_s3_object.user1_avatar.key}"
  profile_image_url_2         = "https://${aws_s3_bucket.avatar_bucket.bucket}.s3.amazonaws.com/${aws_s3_object.user2_avatar.key}"
}


resource "aws_security_group" "db-sg" {
  vpc_id = module.networking.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    description     = "allow postgres traffic only from the app sg"
    security_groups = [aws_security_group.app_sg.id]
  }

  tags = {
    Name = "rds-sg"
  }
}


resource "aws_db_instance" "postgres" {
  allocated_storage      = 20
  engine                 = "postgres"
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
  subnet_ids = module.networking.db_subnet_ids

  tags = {
    Name = "main-subnet-group"
  }
}