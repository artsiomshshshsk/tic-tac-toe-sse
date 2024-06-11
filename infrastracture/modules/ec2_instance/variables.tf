variable "ami" {
  description = "The AMI to use for the instance"
}

variable "instance_type" {
  description = "The type of instance to start"
  default     = "t2.micro"
}

variable "key_name" {
  description = "The key name to use for the instance"
}

variable "security_group_id" {
  description = "The ID of the security group to associate with the instance"
}

variable "instance_name" {
  description = "The name tag for the instance"
  default     = "Tic-Tac-Toe-App"
}

variable "subnet_ids" {
  description = "The ID of the subnet to launch the instance in"
}

variable "cognito_user_pool_id" {
  description = "The user pool ID"
  type        = string
}

variable "cognito_user_pool_client_id" {
  description = "The user pool client ID"
  type        = string
}

variable "cognito_user_pool_region" {
  description = "The user pool region"
  type        = string
}

variable "notification_email" {
  description = "The email address to send notifications to"
  type        = string
  default     = "artsiomshablinskiy@gmail.com"
}


variable "vpc_id" {
    description = "The ID of the VPC"
    type        = string
}

variable "rds_endpoint" {
    description = "The endpoint of the RDS instance"
    type        = string
}

variable "profile_image_url_1" {
    description = "The URL of the first profile image"
    type        = string
}

variable "profile_image_url_2" {
    description = "The URL of the second profile image"
    type        = string
}

variable "aws_access_key_id" {
    description = "The AWS access key ID"
    type        = string
}

variable "aws_secret_access_key" {
    description = "The AWS secret access key"
    type        = string
}

variable "aws_session_token" {
    description = "The AWS session token"
    type        = string
}