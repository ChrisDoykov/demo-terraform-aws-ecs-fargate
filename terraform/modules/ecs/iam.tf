# IAM Role for ECS Task execution

resource "aws_iam_role" "ecs_task_execution_role" {
  provider           = aws.main
  name               = "${var.namespace}_ECS_TaskExecutionRole_${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.task_assume_role_policy.json
}

# Policy for the role

data "aws_iam_policy_document" "task_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Attach the policy

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  provider   = aws.main
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Role for the Tasks (permissions can be altered as needed)

resource "aws_iam_role" "ecs_task_iam_role" {
  provider           = aws.main
  name               = "${var.namespace}_ECS_TaskIAMRole_${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.task_assume_role_policy.json
}