resource "aws_instance" "app_instance" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  user_data              = file(var.user_data_path)
  vpc_security_group_ids = [var.security_group_id]
  subnet_id              = var.subnet_id
  associate_public_ip_address = true

  tags = {
    Name = var.instance_name
  }
}