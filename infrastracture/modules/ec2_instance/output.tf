output "lb_dns_name" {
  description = "DNS of Load balancer"
  value       = aws_lb.app_lb.dns_name
}