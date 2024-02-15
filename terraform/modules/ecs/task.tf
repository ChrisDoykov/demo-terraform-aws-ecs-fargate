resource "aws_ecs_task_definition" "default" {
  provider                 = aws.main
  family                   = "${var.namespace}_ECS_TaskDefinition_${var.environment}"
  requires_compatibilities = ["FARGATE"] # Declares this a container to be managed by Fargate
  network_mode             = "awsvpc"    # Requirement for Fargate
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_iam_role.arn
  cpu                      = var.cpu_units
  memory                   = var.memory

  container_definitions = jsonencode([
    {
      name      = var.service_name
      image     = "${var.repo_url}:${var.image_version}"
      cpu       = var.cpu_units
      memory    = var.memory
      essential = true
      portMappings = [
        {
          containerPort = var.container_port,
          hostPort      = var.container_port,
          protocol      = "tcp"
        }
      ]
      # Connect to our log group
      logConfiguration : {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.log_group.name,
          "awslogs-region"        = var.region,
          "awslogs-stream-prefix" = "${var.service_name}-log-stream-${var.environment}"
        }
      },
    }
  ])

  # Very important gotcha if your image was built for ARM64 like on an M1 Mac for instance (ensures FARGATE is also using ARM64)
  # If running on M1 you can also leave this as is and add the --platform=linux/amd64 flag to your docker FROM command
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}