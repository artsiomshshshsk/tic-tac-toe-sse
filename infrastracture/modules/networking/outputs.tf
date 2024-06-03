output "vpc_id" {
  value = aws_vpc.app_vpc.id
}

output "subnet_ids" {
  value = [
      aws_subnet.app_subnet_1.id,
      aws_subnet.app_subnet_2.id
  ]
}