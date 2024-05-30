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

echo "Downloading docker-compose.yml"

curl -o docker-compose.yml https://raw.githubusercontent.com/artsiomshshshsk/tic-tac-toe-sse/main/docker-compose.yml

echo "Running docker compose pull"

sudo docker compose pull

echo "Creating .env file"

touch .env
echo "AWS_COGNITO_CLIENT_ID=${aws_cognito_client_id}" >> .env
echo "AWS_COGNITO_USER_POOL_ID=${aws_cognito_user_pool_id}" >> .env
echo "AWS_REGION=${aws_region}" >> .env

echo "Contents of .env file:"
cat .env


echo "Running docker compose up"

sudo docker compose up --no-build

echo "Script completed"