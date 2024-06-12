locals {
  user_data_template = templatefile("${path.module}/user-data.sh.tpl", {
    aws_cognito_user_pool_id = var.cognito_user_pool_id
    aws_cognito_client_id    = var.cognito_user_pool_client_id
    aws_region               = var.cognito_user_pool_region
    rds_endpoint             = var.rds_endpoint
    profile_image_url_1      = var.profile_image_url_1
    profile_image_url_2      = var.profile_image_url_2
    aws_access_key_id        = var.aws_access_key_id
    aws_secret_access_key    = var.aws_secret_access_key
    aws_session_token        = var.aws_session_token
  })
}


resource "aws_instance" "app_instance" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [var.security_group_id]
  subnet_id                   = var.subnet_ids[0]
  associate_public_ip_address = true
  tags                        = {
    Name = var.instance_name
  }
  user_data = local.user_data_template
}
