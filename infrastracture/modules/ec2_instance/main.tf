locals {
  user_data_template = templatefile("${path.module}/user-data.sh.tpl", {
    aws_cognito_user_pool_id = var.cognito_user_pool_id
    aws_cognito_client_id    = var.cognito_user_pool_client_id
    aws_region               = var.cognito_user_pool_region
  })
}


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
  user_data = local.user_data_template
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
