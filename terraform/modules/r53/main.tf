terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Create Route53 Hosted Zone for the domain of the service including NS records in the top level domain.
# For this scenario, we assume that the service is running on a subdomain, like service.example.com.

data "external" "get_r53_zone" {
  program = ["bash", "${path.module}/get_or_create_r53_zone.sh"]

  query = {
    zone_name = var.domain_name
  }
}

resource "aws_route53_record" "ns_record" {
  zone_id         = var.tld_zone_id
  name            = var.domain_name
  type            = "NS"
  ttl             = 300
  records         = jsondecode(data.external.get_r53_zone.result.name_servers)
  allow_overwrite = true
}

# Hosted zone for development subdomain of our service

resource "aws_route53_zone" "environment" {
  name = "${var.environment}.${var.domain_name}"
}

resource "aws_route53_record" "environment" {
  zone_id = data.external.get_r53_zone.result.id
  name    = aws_route53_zone.environment.name
  type    = "NS"
  ttl     = 300
  records = aws_route53_zone.environment.name_servers
}

# Point A record to CloudFront distribution

resource "aws_route53_record" "service_record" {
  name            = "${var.environment}.${var.domain_name}"
  type            = "A"
  zone_id         = aws_route53_zone.environment.id
  allow_overwrite = true

  alias {
    name                   = var.cloudfront_distribution_domain_name
    zone_id                = var.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = false
  }
}