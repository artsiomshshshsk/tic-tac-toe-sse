#!/bin/bash
sudo apt update
sudo apt -y upgrade
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
sudo systemctl start docker
sudo systemctl enable docker
docker --version

sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
sudo chmod 777 /var/run/docker.sock

git clone https://github.com/artsiomshshshsk/tic-tac-toe-sse.git
cd tic-tac-toe-sse/

sudo docker-compose pull
sudo docker-compose up --no-build

echo "Script completed"
echo "Script completed" > /var/tmp/script-completed.flag