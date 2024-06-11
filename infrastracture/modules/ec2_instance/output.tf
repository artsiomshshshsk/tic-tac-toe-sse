#output "lb_dns_name" {
#  description = "DNS of Load balancer"
#  value       = aws_lb.app_lb.dns_name
#}


output "instance_public_ip" {
  value = aws_instance.app_instance.public_ip
}