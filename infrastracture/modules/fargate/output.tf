output "cluster_id" {
  value = aws_ecs_cluster.app_cluster.id
  description = "The ID of the ECS cluster"
}

output "service_name" {
  value = aws_ecs_service.app_service.name
  description = "The name of the ECS service"
}
