resource "aws_cognito_user_pool" "tic-tac-toe-user-pool" {
  name                     = var.user_pool_name
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 6
    require_lowercase = false
    require_numbers   = false
    require_symbols   = false
    require_uppercase = false
  }
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


resource "aws_cognito_user" "user1" {
  user_pool_id = aws_cognito_user_pool.tic-tac-toe-user-pool.id
  username     = "user1"
  password     = "password1"

  attributes = {
    email          = "email1@google.com"
    email_verified = true
  }
}

resource "aws_cognito_user" "user2" {
  user_pool_id = aws_cognito_user_pool.tic-tac-toe-user-pool.id
  username     = "user2"
  password     = "password2"

  attributes = {
    email          = "email2@google.com"
    email_verified = true
  }
}

resource "aws_s3_bucket" "avatar_bucket" {
  bucket = "tic-tac-toe-bucket-34cb38ee-927a-4f5f-a5e0-bd5bfabe6fd6"

  tags = {
    Name = "Avatar Bucket"
  }
}
