resource "aws_ecs_service" "ecs_service" {
  provider                           = aws.main
  name                               = "${var.namespace}_ECS_Service_${var.environment}"
  cluster                            = aws_ecs_cluster.default.id
  task_definition                    = aws_ecs_task_definition.default.arn
  desired_count                      = var.ecs_task_desired_count
  deployment_minimum_healthy_percent = var.ecs_task_deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.ecs_task_deployment_maximum_percent
  launch_type                        = "FARGATE"
  health_check_grace_period_seconds  = 30

  # Expose our deployment using a load balancer
  load_balancer {
    target_group_arn = aws_lb_target_group.service_target_group.arn
    container_name   = var.service_name
    container_port   = var.container_port
  }

  network_configuration {
    security_groups  = [aws_security_group.ecs_container_instance.id]
    subnets          = var.private_subnets
    assign_public_ip = false
  }

  # Redeploy service on every apply (ensure task version is always correct after a push)
  force_new_deployment = true
  triggers = {
    redeployment = plantimestamp()
  }

  lifecycle {
    # Allow external changes without Terraform plan difference (e.g. via AWS console)
    ignore_changes = [desired_count]
  }

  depends_on = [aws_lb_listener.alb_default_listener_https, aws_lb_listener_rule.https_listener_rule]
}

# Security Group for ECS Task Container Instances (managed by Fargate)

resource "aws_security_group" "ecs_container_instance" {
  provider    = aws.main
  name        = "${var.namespace}_ECS_Task_SecurityGroup_${var.environment}"
  description = "Security group for ECS task running on Fargate"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow ingress traffic from ALB on HTTP only"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow all egress traffic"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.namespace}_ECS_Task_SecurityGroup_${var.environment}"
  }
}