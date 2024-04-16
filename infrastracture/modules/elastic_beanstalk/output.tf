output "app_name" {
  value = aws_elastic_beanstalk_application.app.name
}

output "env_name" {
  value = aws_elastic_beanstalk_environment.env.name
}