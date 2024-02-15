output "ecr_repo_arn" {
  # value       = data.external.get_ecr_repo.result.exists == "true" ? data.external.get_ecr_repo.result.arn : aws_ecr_repository.ecr_repo[0].arn
  value       = aws_ecr_repository.ecr_repo.arn
  description = "The ARN of the created ECR repository"
}
output "ecr_repo_url" {
  # value       = data.external.get_ecr_repo.result.exists == "true" ? data.external.get_ecr_repo.result.repository_url : aws_ecr_repository.ecr_repo[0].repository_url
  value       = aws_ecr_repository.ecr_repo.repository_url
  description = "The URL of the created ECR repository"
}
output "ecr_repo_registry" {
  # value       = trimsuffix((data.external.get_ecr_repo.result.exists == "true" ? data.external.get_ecr_repo.result.repository_url : aws_ecr_repository.ecr_repo[0].repository_url), "/${lower(var.namespace)}/${var.environment}/${var.service_name}")
  value       = trimsuffix(aws_ecr_repository.ecr_repo.repository_url, "/${lower(var.namespace)}/${var.environment}/${var.service_name}")
  description = "The registry ID of the created ECR repository"
}
