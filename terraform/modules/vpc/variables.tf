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
variable "vpc_cidr_block" {
  type        = string
  default     = ""
  description = "THe CIDR block for the VPC, such as 10.0.0.0/16 (most possible IPs) or 10.0.0.0/28 (least possible IPs)"
}
variable "az_count" {
  type        = string
  default     = "2"
  description = "The number of AZs in the region"
}
