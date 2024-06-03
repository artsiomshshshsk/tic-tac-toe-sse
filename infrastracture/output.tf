output "cognito_user_pool_id" {
  value = module.cognito.user_pool_id
}

output "cognito_user_pool_client_id" {
  value = module.cognito.client_id
}

output "ec2_public_ip" {
  value = module.ec2[0].instance_public_ip
}