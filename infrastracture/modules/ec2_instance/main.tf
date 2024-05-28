resource "aws_instance" "app_instance" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [var.security_group_id]
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true

  tags = {
    Name = var.instance_name
  }

  user_data = <<-EOF
              #!/bin/bash

              for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
                  sudo apt-get remove -y $pkg
              done

              # Add Docker's official GPG key:
              sudo apt-get update
              sudo apt-get install -y ca-certificates curl
              sudo install -m 0755 -d /etc/apt/keyrings
              sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
              sudo chmod a+r /etc/apt/keyrings/docker.asc

              # Add the repository to Apt sources:
              echo \
                "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
                $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
                sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
              sudo apt-get update

              sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

              docker -v

              export AWS_COGNITO_CLIENT_ID=${var.cognito_user_pool_client_id}
              export AWS_COGNITO_USER_POOL_ID=${var.cognito_user_pool_id}
              export AWS_REGION=${var.cognito_user_pool_region}

              echo "Downloading docker-compose.yml"

              curl -o docker-compose.yml https://raw.githubusercontent.com/artsiomshshshsk/tic-tac-toe-sse/main/docker-compose.yml

              echo "Running docker compose pull"

              sudo docker compose pull

              echo "Running docker compose up"

              sudo docker compose up --no-build

              echo "Script completed"

              EOF
}