locals {
  user_data_template = templatefile("${path.module}/user-data.sh.tpl", {
    aws_cognito_user_pool_id = var.cognito_user_pool_id
    aws_cognito_client_id    = var.cognito_user_pool_client_id
    aws_region               = var.cognito_user_pool_region
  })
}

#
# resource "aws_instance" "app_instance" {
#   ami                         = var.ami
#   instance_type               = var.instance_type
#   key_name                    = var.key_name
#   vpc_security_group_ids      = [var.security_group_id]
#   subnet_id                   = var.subnet_id
#   associate_public_ip_address = true
#
#   tags = {
#     Name = var.instance_name
#   }
#   user_data = local.user_data_template
# }

#
# resource "aws_sns_topic" "cpu_alarm_topic" {
#   name = "cpu-alarm-topic"
# }
#
# resource "aws_sns_topic_subscription" "cpu_alarm_subscription" {
#   topic_arn = aws_sns_topic.cpu_alarm_topic.arn
#   protocol  = "email"
#   endpoint  = var.notification_email
# }
#
# resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm" {
#   alarm_name                = "HighCPUUtilization"
#   comparison_operator       = "GreaterThanThreshold"
#   evaluation_periods        = "1"
#   metric_name               = "CPUUtilization"
#   namespace                 = "AWS/EC2"
#   period                    = "60"
#   statistic                 = "Average"
#   threshold                 = "20"
#   alarm_description         = "This alarm monitors EC2 CPU Utilization"
#   alarm_actions             = [aws_sns_topic.cpu_alarm_topic.arn]
#   ok_actions                = [aws_sns_topic.cpu_alarm_topic.arn]
#   insufficient_data_actions = [aws_sns_topic.cpu_alarm_topic.arn]
#   dimensions = {
#     InstanceId = aws_instance.app_instance.id
#   }
# }
#
#
# resource "aws_cloudwatch_metric_alarm" "ec2_instance_status_alarm" {
#   alarm_name                = "EC2InstanceStatusCheckFailed"
#   comparison_operator       = "GreaterThanThreshold"
#   evaluation_periods        = "1"
#   metric_name               = "StatusCheckFailed"
#   namespace                 = "AWS/EC2"
#   period                    = "60"
#   statistic                 = "Average"
#   threshold                 = "1"
#   alarm_description         = "This alarm monitors EC2 instance status checks"
#   alarm_actions             = [aws_sns_topic.cpu_alarm_topic.arn]
#   ok_actions                = [aws_sns_topic.cpu_alarm_topic.arn]
#   insufficient_data_actions = [aws_sns_topic.cpu_alarm_topic.arn]
#   dimensions = {
#     InstanceId = aws_instance.app_instance.id
#   }
# }



resource "aws_launch_template" "app_launch_template" {
  name          = "app-launch-template"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interfaces {
    security_groups             = [var.security_group_id]
    associate_public_ip_address = true
  }

  user_data = base64encode(local.user_data_template)

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.instance_name
    }
  }
}


resource "aws_autoscaling_group" "app_asg" {
  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }

  min_size            = 1
  max_size            = 3
  desired_capacity    = 1
  vpc_zone_identifier = [var.subnet_id]

  tag {
    key                 = "Name"
    value               = var.instance_name
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_sns_topic" "scale_alarm_topic" {
  name = "scale-alarm-topic"
}

resource "aws_sns_topic_subscription" "scale_alarm_subscription" {
  topic_arn = aws_sns_topic.scale_alarm_topic.arn
  protocol  = "email"
  endpoint  = var.notification_email
}


resource "aws_autoscaling_policy" "scale_up_policy" {
  name                   = "scale-up-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 30
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

resource "aws_autoscaling_policy" "scale_down_policy" {
  name                   = "scale-down-policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 30
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}


resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name          = "ScaleUpAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "0"
  alarm_description   = "Alarm to scale up instances when CPU utilization is high"
  alarm_actions       = [
    aws_autoscaling_policy.scale_up_policy.arn,
    aws_sns_topic.scale_alarm_topic.arn
  ]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
}


# resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
#   alarm_name          = "ScaleDownAlarm"
#   comparison_operator = "LessThanThreshold"
#   evaluation_periods  = "1"
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"
#   period              = "60"
#   statistic           = "Average"
#   threshold           = "1"
#   alarm_description   = "Alarm to scale down instances when CPU utilization is low"
#   alarm_actions       = [aws_autoscaling_policy.scale_down_policy.arn]
#   dimensions = {
#     AutoScalingGroupName = aws_autoscaling_group.app_asg.name
#   }
# }
