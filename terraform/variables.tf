################################################
## REQUIRED VARIABLES
################################################
variable "aws_access_key_id" {
  type = string
}
variable "aws_secret_access_key" {
  type = string
}
variable "region" {
  type        = string
  description = "The AWS region to be used"
}
variable "domain_name" {
  type = string
}
variable "tld_zone_id" {
  type        = string
  description = "The zone for the top level domain"
}
variable "environment" {
  type        = string
  description = "The slug for the environment"
}
variable "vpc_cidr_block" {
  type        = string
  description = "THe CIDR block for the VPC, such as 10.0.0.0/16 (most possible IPs) or 10.0.0.0/28 (least possible IPs)"
}
variable "namespace" {
  type        = string
  description = "The namespace to use for the ECR repository (such as demos, dev, or production)"
}
variable "ecr_force_delete" {
  type        = bool
  description = "Whether to empty out the ECR repo of all images and delete the repo itself when terraform destroy is ran. Should be false for production."
}
variable "service_name" {
  type        = string
  description = "The name of the service/container (such as nodejs_api or react_client). Will be used in the ECR repository name"
}
variable "container_port" {
  type        = number
  description = "The port which the container will listen on"
}
variable "image_version" {
  type        = string
  description = "The exact image version to use for the ECS task. Usually set by CI/CD or 'latest' for local dev."
}
variable "custom_origin_host_header_value" {
  type        = string
  description = "The value of the X-Custom-Header custom header in order to pass the rule and access the ALB"
}
################################################
## END REQUIRED VARIABLES
################################################

variable "az_count" {
  type        = number
  default     = 2
  description = "The number of AZs in the region (min 2)"
}
variable "ecs_task_desired_count" {
  type        = number
  default     = 3
  description = "The number of replicas for the ECS task"
}
variable "ecs_task_deployment_minimum_healthy_percent" {
  type        = number
  default     = 33
  description = "The minimum replicas (as a percentage of the desiredCount) to consider healthy for the ECS task"
}
variable "ecs_task_deployment_maximum_percent" {
  type        = number
  default     = 150
  description = "The maximum replicas (as a percentage of the desiredCount) to allow to be running for the ECS task"
}
variable "cpu_units" {
  type        = number
  default     = 256
  description = "CPU units to use for the ECS task"
}
variable "memory" {
  type        = number
  default     = 512
  description = "Memory to allocate for the ECS task"
}
variable "log_retention_in_days" {
  type        = number
  default     = 3
  description = "The number of days to retain log events for the ECS task"
}
variable "healthcheck_matcher" {
  type        = string
  default     = "200"
  description = "Matcher string for the health check of the ECS Task"
}
variable "healthcheck_endpoint" {
  type        = string
  default     = "/health"
  description = "Health check endpoint for the ECS Task"
}
variable "ecs_task_min_count" {
  type        = number
  default     = 2
  description = "How many ECS task instances should minimally run in parallel"
}
variable "ecs_task_max_count" {
  type        = number
  default     = 3
  description = "How many ECS task instances should maximally run in parallel"
}
variable "cpu_target_tracking_desired_value" {
  type        = number
  default     = 70
  description = "Target tracking for CPU usage in % (if usage is consistently above this value, scale up)"
}
variable "memory_target_tracking_desired_value" {
  type        = number
  default     = 80
  description = "Target tracking for memory usage in % (if usage is consistently above this value, scale up)"
}