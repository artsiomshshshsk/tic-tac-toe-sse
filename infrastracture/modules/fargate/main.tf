locals {
  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = "artsiomshshshsk/cloud-programming-lab:tic-tac-toe-back-fargate"
      essential = true
      portMappings = [
        {
          containerPort = 8081,
          hostPort      = 8081,
          protocol      = "tcp"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.backend_log_group.name,
          "awslogs-region"        = "us-east-1",
          "awslogs-stream-prefix" = "backend"
        }
      }
    },
    {
      name       = "frontend"
      image      = "artsiomshshshsk/cloud-programming-lab:tic-tac-toe-front-fargate"
      essential  = true
      portMappings = [
        {
          containerPort = 8080,
          hostPort      = 8080,
          protocol      = "tcp"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.frontend_log_group.name,
          "awslogs-region"        = "us-east-1",
          "awslogs-stream-prefix" = "frontend"
        }
      }
      dependsOn = [
        {
          containerName = "backend",
          condition     = "START"
        }
      ]
    }
  ])
}






resource "aws_ecs_cluster" "app_cluster" {
  name = var.cluster_name
}

resource "aws_cloudwatch_log_group" "backend_log_group" {
  name = "/ecs/${var.cluster_name}-backend"
}

resource "aws_cloudwatch_log_group" "frontend_log_group" {
  name = "/ecs/${var.cluster_name}-frontend"
}

resource "aws_ecs_task_definition" "app_task" {
  family                   = "${var.cluster_name}-task"
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = data.aws_iam_role.role_lab.arn
  container_definitions    = local.container_definitions
}

resource "aws_ecs_service" "app_service" {
  name            = "${var.cluster_name}-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnets
    security_groups = var.security_groups
    assign_public_ip = var.assign_public_ip
  }
}
