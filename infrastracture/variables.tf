variable "region" {
  description = "The AWS region to create resources in"
  type        = string
  default     = "us-east-1"
}

variable "ssh-public-key" {
  description = "Public ssh key location "
  type        = string
  default     = "~/.ssh/cloud-key.pub"
}

variable "ssh-private-key" {
  description = "Private ssh key location "
  type        = string
  default     = "~/.ssh/cloud-key"
}

variable "ec2-ami" {
  description = "AMI of EC2"
  type        = string
  default     = "ami-080e1f13689e07408"
}

variable "ec2_deployment" {
  description = "EC2 deployment"
  type        = bool
  default     = false
}

variable "beanstalk_deployment" {
  description = "Beanstalk deployment"
  type        = bool
  default     = false
}


variable "fargate_deployment" {
  description = "Fargate deployment"
  type        = bool
  default     = true
}

variable "infrastructure_deployment" {
  description = "Infrastructure deployment (security groups, vpc, subnets, etc)"
  type        = bool
  default     = false
}

variable "cognito_deployment" {
  description = "Cognito deployment"
  type        = bool
  default     = true
}


