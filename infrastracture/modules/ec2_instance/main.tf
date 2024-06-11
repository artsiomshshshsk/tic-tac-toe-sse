locals {
  user_data_template = templatefile("${path.module}/user-data.sh.tpl", {
    aws_cognito_user_pool_id = var.cognito_user_pool_id
    aws_cognito_client_id    = var.cognito_user_pool_client_id
    aws_region               = var.cognito_user_pool_region
    rds_endpoint             = var.rds_endpoint
    profile_image_url_1      = var.profile_image_url_1
    profile_image_url_2      = var.profile_image_url_2
  })
}

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


resource "aws_security_group" "lb_sg" {
  name        = "lb-security-group"
  description = "Security group for the load balancer"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "app-lb"
  }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    interval            = 10
    path                = "/api/actuator/health"
    timeout             = 5
    healthy_threshold   = 6
    unhealthy_threshold = 2
    matcher             = "200-299"
  }

  tags = {
    Name = "app-tg"
  }
}


resource "aws_lb_listener" "app_lb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}


resource "aws_autoscaling_group" "app_asg" {
  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }

  min_size            = 1
  max_size            = 10
  desired_capacity    = 1
  vpc_zone_identifier = var.subnet_ids

  health_check_type = "ELB"
  health_check_grace_period = 60 # Grace period in seconds
  target_group_arns = [aws_lb_target_group.app_tg.arn]

  tag {
    key                 = "Name"
    value               = var.instance_name
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  enabled_metrics = ["GroupInServiceInstances"]
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
  alarm_name          = "cpu-utilization-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "60"
  alarm_description   = "This metric monitors the average CPU utilization"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
  alarm_actions = [aws_sns_topic.cpu_alarm_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "no_instances_running_alarm" {
  alarm_name          = "no-instances-running-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "GroupInServiceInstances"
  namespace           = "AWS/AutoScaling"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "1"
  alarm_description   = "Alarm when no instances are running in the Auto Scaling group"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
  alarm_actions = [aws_sns_topic.cpu_alarm_topic.arn]
  ok_actions    = [aws_sns_topic.cpu_alarm_topic.arn]
}


resource "aws_autoscaling_policy" "scale_up_policy" {
  name                   = "scale-up-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

resource "aws_autoscaling_policy" "scale_down_policy" {
  name                   = "scale-down-policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization_alarm" {
  alarm_name          = "high-cpu-utilization-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "70"  # Scale up if CPU utilization > 70%
  alarm_description   = "Alarm when CPU utilization is high"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
  alarm_actions = [
    aws_sns_topic.cpu_alarm_topic.arn,
    aws_autoscaling_policy.scale_up_policy.arn
  ]
}

resource "aws_cloudwatch_metric_alarm" "low_cpu_utilization_alarm" {
  alarm_name          = "low-cpu-utilization-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "30"  # Scale down if CPU utilization < 30%
  alarm_description   = "Alarm when CPU utilization is low"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
  alarm_actions = [
    aws_sns_topic.cpu_alarm_topic.arn,
    aws_autoscaling_policy.scale_down_policy.arn
  ]
}

