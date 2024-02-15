# Create log group for our service

resource "aws_cloudwatch_log_group" "log_group" {
  provider          = aws.main
  name              = "/${lower(var.namespace)}/${var.environment}/ecs/${var.service_name}"
  retention_in_days = var.log_retention_in_days
}