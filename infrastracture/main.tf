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

# resource "aws_key_pair" "deployer" {
#   key_name   = "deployer-key"
#   public_key = file(var.ssh-public-key)
# }
#
# module "security" {
#   source = "./modules/security"
#   vpc_id = module.networking.vpc_id
# }
#
# module "networking" {
#   source     = "./modules/networking"
#   cidr_block = "10.0.0.0/16"
# }
#
# module "elastic_beanstalk" {
#   source              = "./modules/elastic_beanstalk"
#   count               = var.beanstalk_deployment ? 1 : 0
#   application_name    = "tic-tac-toe-app"
#   description         = "Tic Tac Toe application"
#   solution_stack_name = "64bit Amazon Linux 2023 v4.3.0 running Docker"
#   version_label       = "1.0.0"
#   instance_type       = "t2.micro"
#   key_name            = aws_key_pair.deployer.key_name
#   vpc_id              = module.networking.vpc_id
#   subnet_ids          = [module.networking.subnet_id]
#   security_group_ids  = [module.security.security_group_id]
# }
#
# module "ec2" {
#   source            = "./modules/ec2_instance"
#   count             = var.ec2_deployment ? 1 : 0
#   ami               = var.ec2-ami
#   instance_type     = "t2.micro"
#   key_name          = aws_key_pair.deployer.key_name
#   user_data_path    = "./setup-script.sh"
#   security_group_id = module.security.security_group_id
#   subnet_id         = module.networking.subnet_id
# }
#
#
# module "fargate" {
#   count                       = var.fargate_deployment ? 1 : 0
#   source                      = "./modules/fargate"
#   cluster_name                = "tic-tac-toe-cluster"
#   cpu                         = "256"
#   memory                      = "512"
#   desired_count               = 1
#   subnets                     = [module.networking.subnet_id]
#   security_groups             = [module.security.security_group_id]
#   assign_public_ip            = true
#   cognito_user_pool_client_id = module.cognito.client_id
#   cognito_user_pool_id        = module.cognito.user_pool_id
#   cognito_user_pool_region    = var.region
# }

module "cognito" {
  source                = "./modules/cognito"
  user_pool_client_name = "tic-tac-toe-user-pool-client"
  user_pool_name        = "tic-tac-toe-user-pool"
  user_pool_domain_name = "ttt-user-pool"
}