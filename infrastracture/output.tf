output "cognito_user_pool_id" {
  value = module.cognito.user_pool_id
}

output "cognito_user_pool_client_id" {
  value = module.cognito.client_id
}

output "dns_lb_name" {
  value = module.ec2[0].lb_dns_name
}