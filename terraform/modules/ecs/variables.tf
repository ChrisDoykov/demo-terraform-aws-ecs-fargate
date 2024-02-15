variable "domain_name" {
  type    = string
  default = ""
}
variable "namespace" {
  type        = string
  default     = ""
  description = "The namespace to use for the ECR repository (such as demo_apps or production"
}
variable "environment" {
  type        = string
  default     = "dev"
  description = "The slug for the environment"
}
variable "ecs_task_desired_count" {
  type        = number
  default     = 3
  description = "The number of replicas for the ECS task"
}
variable "ecs_task_deployment_minimum_healthy_percent" {
  type        = number
  default     = 25
  description = "The minimum replicas (as a percentage of the desiredCount) to consider healthy for the ECS task"
}
variable "ecs_task_deployment_maximum_percent" {
  type        = number
  default     = 150
  description = "The maximum replicas (as a percentage of the desiredCount) to allow to be running for the ECS task"
}
variable "service_name" {
  type        = string
  default     = ""
  description = "The name of the container to be run by the ECS Task"
}
variable "container_port" {
  type        = number
  default     = 3000
  description = "The port on which the container will listen"
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
variable "repo_url" {
  type        = string
  default     = ""
  description = "ECR repository image URL"
}
variable "image_version" {
  type        = string
  description = "The exact image version to use for the ECS task. Usually set by CI/CD or 'latest' for local dev."
}
variable "log_retention_in_days" {
  type        = number
  default     = 3
  description = "The number of days to retain log events for the ECS task"
}
variable "region" {
  type        = string
  default     = ""
  description = "The AWS region to be used"
}
variable "custom_origin_host_header_value" {
  type        = string
  default     = "secret"
  description = "The value of the X-Custom-Header custom header in order to pass the rule and access the ALB"
}
variable "healthcheck_matcher" {
  type        = string
  default     = "200"
  description = "Matcher string for the health check of the ECS Task"
}
variable "healthcheck_endpoint" {
  type        = string
  default     = "200"
  description = "Health check endpoint for the ECS Task"
}
variable "vpc_id" {
  type        = string
  default     = ""
  description = "The ID of the VPC resource to use"
}
variable "r53_zone_id" {
  type        = string
  default     = ""
  description = "The ID of the R53 Zone resource to use"
}
variable "public_subnets" {
  type        = list(string)
  default     = []
  description = "List of public subnet IDs"
}
variable "private_subnets" {
  type        = list(string)
  default     = []
  description = "List of private subnet IDs"
}
variable "ecs_task_min_count" {
  description = "How many ECS tasks should minimally run in parallel"
  default     = 2
  type        = number
}
variable "ecs_task_max_count" {
  description = "How many ECS tasks should maximally run in parallel"
  default     = 10
  type        = number
}
variable "cpu_target_tracking_desired_value" {
  description = "Target tracking for CPU usage in %"
  default     = 70
  type        = number
}

variable "memory_target_tracking_desired_value" {
  description = "Target tracking for memory usage in %"
  default     = 80
  type        = number
}