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
variable "custom_origin_host_header_value" {
  type        = string
  default     = "secret"
  description = "The value of the X-Custom-Header custom header in order to pass the rule and access the ALB"
}
variable "domain_name" {
  type    = string
  default = ""
}
variable "alb_name" {
  type        = string
  default     = ""
  description = "The name of the Application Load Balancer resource to use"
}
variable "alb_dns_name" {
  type        = string
  default     = ""
  description = "The DNS name of the Application Load Balancer resource to use"
}
variable "cloudfront_certificate_arn" {
  type        = string
  default     = ""
  description = "The ARN of the ACM certificate for CloudFront to use"
}
