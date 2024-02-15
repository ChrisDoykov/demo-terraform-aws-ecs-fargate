output "ecs_cluster_arn" {
  value       = aws_ecs_cluster.default.arn
  description = "The ARN of the ECS cluster"
}
output "iam_user_arn" {
  value       = aws_iam_role.ecs_task_execution_role.arn
  description = "The ARN of the IAM role used by ECS to execute tasks"
}
output "alb_name" {
  value       = aws_lb.alb.name
  description = "The name of the ALB reosource"
}
output "alb_dns_name" {
  value       = aws_lb.alb.dns_name
  description = "The DNS name of the ALB reosource"
}
output "cloudfront_certificate_arn" {
  value       = aws_acm_certificate.cloudfront_certificate.arn
  description = "The ARN of the ACM Certificate for Cloudfront to use"
}
