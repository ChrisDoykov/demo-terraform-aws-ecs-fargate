terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_ecr_repository" "ecr_repo" {
  name         = "${lower(var.namespace)}/${var.environment}/${var.service_name}"
  force_delete = var.ecr_force_delete

  # Enable vulnerability scanning on all images
  image_scanning_configuration {
    scan_on_push = true
  }
}

# Enforce a policy that will remove obsolete images 
resource "aws_ecr_lifecycle_policy" "ecr_repo_lifecycle_policy" {
  repository = aws_ecr_repository.ecr_repo.name

  policy = jsonencode(
    {
      rules = [
        {
          rulePriority = 1,
          description  = "Expire images older than 14 days",
          selection = {
            tagStatus   = "untagged",
            countType   = "sinceImagePushed",
            countUnit   = "days",
            countNumber = 14
          },
          action = {
            type = "expire"
          }
        },
        {
          rulePriority = 2,
          description  = "Keep only the last 30 images",
          selection = {
            tagStatus     = "tagged",
            tagPrefixList = ["v", "latest"],
            countType     = "imageCountMoreThan",
            countNumber   = 30
          },
          action = {
            type = "expire"
          }
        }
      ]
  })
}