variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "cpu" {
  description = "The number of CPU units used by the task"
  type        = string
}

variable "memory" {
  description = "The amount of memory used by the task (in MiB)"
  type        = string
}

variable "desired_count" {
  description = "The number of instances of the task to run"
  type        = number
}

variable "subnets" {
  description = "List of subnet IDs for the ECS service"
  type        = list(string)
}

variable "security_groups" {
  description = "List of security group IDs for the ECS service"
  type        = list(string)
}

variable "assign_public_ip" {
  description = "Assign a public IP address to the ECS tasks"
  type        = bool
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
