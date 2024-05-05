output "user_pool_id" {
  value = aws_cognito_user_pool.tic-tac-toe-user-pool.id
}

output "client_id" {
  value = aws_cognito_user_pool_client.tic-tac-toe-user-pool-client.id
}