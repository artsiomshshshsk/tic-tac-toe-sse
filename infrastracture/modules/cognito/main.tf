resource "aws_cognito_user_pool" "tic-tac-toe-user-pool" {
  name                     = var.user_pool_name
  auto_verified_attributes = ["email"]
}

resource "aws_cognito_user_pool_client" "tic-tac-toe-user-pool-client" {
  name = var.user_pool_client_name

  user_pool_id        = aws_cognito_user_pool.tic-tac-toe-user-pool.id
  explicit_auth_flows = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
  token_validity_units {
    access_token = "minutes"
  }
  access_token_validity = 5
}

resource "aws_cognito_user_pool_domain" "tic-tac-toe-user-pool-domain" {
  domain       = var.user_pool_domain_name
  user_pool_id = aws_cognito_user_pool.tic-tac-toe-user-pool.id
}
