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

variable "beanstalk_deployment" {
  description = "Beanstalk deployment"
  type        = bool
  default     = true
}