variable "namespace" {
  type        = string
  default     = ""
  description = "The namespace to use for the ECR repository (such as demo_apps or production"
}

variable "service_name" {
  type        = string
  default     = ""
  description = "The name of our service (such as nodejs_api or react_client). Will be used in the ECR repository name"
}

variable "ecr_force_delete" {
  type        = bool
  default     = false
  description = "Whether to empty out the ECR repo of all images and delete the repo itself when terraform destroy is ran. Should be false for production."
}
variable "environment" {
  type        = string
  default     = "dev"
  description = "The slug for the environment"
}
