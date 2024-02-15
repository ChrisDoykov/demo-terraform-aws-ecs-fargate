resource "aws_ecs_cluster" "default" {
  provider = aws.main
  name     = "${var.namespace}_ECSCluster_${var.environment}"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.namespace}_ECSCluster_${var.environment}"
  }
}