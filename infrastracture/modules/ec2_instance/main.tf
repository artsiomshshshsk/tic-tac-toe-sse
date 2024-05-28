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

              echo "Creating .env file"

              touch .env
              echo "AWS_COGNITO_CLIENT_ID=${var.cognito_user_pool_client_id}" >> .env
              echo "AWS_COGNITO_USER_POOL_ID=${var.cognito_user_pool_id}" >> .env
              echo "AWS_REGION=${var.cognito_user_pool_region}" >> .env

              echo "Contents of .env file:"
              cat .env

              echo "Downloading docker-compose.yml"

              curl -o docker-compose.yml https://raw.githubusercontent.com/artsiomshshshsk/tic-tac-toe-sse/main/docker-compose.yml

              echo "Running docker compose pull"

              sudo docker compose pull

              echo "Running docker compose up"

              sudo docker compose up --no-build

              echo "Script completed"

              EOF
}


resource "aws_sns_topic" "cpu_alarm_topic" {
  name = "cpu-alarm-topic"
}

resource "aws_sns_topic_subscription" "cpu_alarm_subscription" {
  topic_arn = aws_sns_topic.cpu_alarm_topic.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm" {
  alarm_name                = "HighCPUUtilization"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "20"
  alarm_description         = "This alarm monitors EC2 CPU Utilization"
  alarm_actions             = [aws_sns_topic.cpu_alarm_topic.arn]
  ok_actions                = [aws_sns_topic.cpu_alarm_topic.arn]
  insufficient_data_actions = [aws_sns_topic.cpu_alarm_topic.arn]
  dimensions = {
    InstanceId = aws_instance.app_instance.id
  }
}
