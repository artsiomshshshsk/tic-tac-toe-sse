output "cognito_user_pool_id" {
  value = module.cognito.user_pool_id
}

output "cognito_user_pool_client_id" {
  value = module.cognito.client_id
}

output "instance_public_ip" {
  value = module.ec2[0].instance_public_ip
}

#output "dns_lb_name" {
#  value = module.ec2[0].lb_dns_name
#}

#output "user1_avatar_url" {
#  value = module.cognito.user1_avatar_url
#}
#
#output "user2_avatar_url" {
#  value = module.cognito.user2_avatar_url
#}


output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "rds_db_name" {
  value = aws_db_instance.postgres.db_name
}
#output "rds_connection_url" {
#  value = "postgresql://${aws_db_instance.postgres.username}:${aws_db_instance.postgres.password}@${aws_db_instance.postgres.endpoint}/${aws_db_instance.postgres.}"
#}