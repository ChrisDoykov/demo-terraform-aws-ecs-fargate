output "ecr_repo_arn" {
  value       = module.ecr.ecr_repo_arn
  description = "The ARN of the created ECR repository"
}
output "ecs_cluster_arn" {
  value       = module.ecs.ecs_cluster_arn
  description = "The ARN of the ECS cluster"
}
output "iam_user_arn" {
  value       = module.ecs.iam_user_arn
  description = "The ARN of the user used to execute ECS tasks"
}
output "ecr_repo_url" {
  value       = module.ecr.ecr_repo_url
  description = "The URL of the created ECR repository"
}
output "ecr_repo_registry" {
  value       = module.ecr.ecr_repo_registry
  description = "The registry ID of the created ECR repository"
}
