variable "environment" {
  type        = string
  default     = "dev"
  description = "The slug for the environment"
}
variable "domain_name" {
  type    = string
  default = ""
}
variable "tld_zone_id" {
  type        = string
  default     = ""
  description = "The zone for the top level domain"
}
variable "service_name" {
  type        = string
  default     = ""
  description = "The name of the container to be run by the ECS Task"
}
variable "cloudfront_distribution_domain_name" {
  type        = string
  default     = ""
  description = "The domain name for the CloudFront distribution"
}
variable "cloudfront_distribution_hosted_zone_id" {
  type        = string
  default     = ""
  description = "The hosted zone ID of the zone hosting the CloudFront distribution"
}