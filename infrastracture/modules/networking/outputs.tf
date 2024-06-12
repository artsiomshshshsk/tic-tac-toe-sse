output "vpc_id" {
  value = aws_vpc.app_vpc.id
}


output "app_subnet" {
  value = aws_subnet.app_subnet
}

output "db_subnet_ids" {
  value = [aws_subnet.db_subnet1.id, aws_subnet.db_subnet2.id]
}