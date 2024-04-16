variable "application_name" {
  description = "The name of the Elastic Beanstalk application"
  type        = string
}

variable "description" {
  description = "The description of the Elastic Beanstalk application"
  type        = string
}

variable "solution_stack_name" {
  description = "The name of the solution stack"
  type        = string
}

variable "version_label" {
  description = "A label identifying the version of the application"
  type        = string
}

variable "bucket" {
  description = "The S3 bucket that stores the application versions"
  type        = string
}

variable "key" {
  description = "The S3 key where the application version is stored"
  type        = string
}

variable "instance_profile" {
  description = "The IAM instance profile for the Elastic Beanstalk environment"
  type        = string
}

variable "instance_type" {
  description = "The instance type for the Elastic Beanstalk environment"
  type        = string
}

variable "key_name" {
  description = "The EC2 key pair name"
  type        = string
}

variable "associate_public_ip_address" {
  description = "Whether to associate public IP addresses to instances"
  type        = bool
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs for the Elastic Beanstalk environment"
  type        = list(string)
}

variable "security_group_ids" {
  description = "A list of security group IDs for the Elastic Beanstalk environment"
  type        = list(string)
}