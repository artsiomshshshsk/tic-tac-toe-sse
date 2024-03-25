output "ssh-connection-string" {
  description = "SSH connection string to ec2"
  value       = "ssh -i ${var.ssh-private-key} ubuntu@${aws_instance.app_instance.public_ip}"
}