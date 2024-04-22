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

variable "user_data_path" {
  description = "Path to the user data script"
}

variable "security_group_id" {
  description = "The ID of the security group to associate with the instance"
}

variable "instance_name" {
  description = "The name tag for the instance"
  default     = "Tic-Tac-Toe-App"
}

variable "subnet_id" {
  description = "The ID of the subnet to launch the instance in"
}