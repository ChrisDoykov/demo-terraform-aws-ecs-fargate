terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_cloudfront_distribution" "default" {
  comment         = "${var.namespace} CloudFront Distribution"
  enabled         = true
  is_ipv6_enabled = true
  aliases         = ["${var.environment}.${var.domain_name}"]

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = var.alb_name
    viewer_protocol_policy = "redirect-to-https"

    # Forward all headers, cookies, and query string values
    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
      }
    }
  }

  origin {
    domain_name = var.alb_dns_name
    origin_id   = var.alb_name

    custom_header {
      name  = "X-Custom-Header" # Give this header a more meaningful name
      value = var.custom_origin_host_header_value
    }

    # Do not allow connections over HTTP, only HTTPS
    custom_origin_config {
      origin_read_timeout      = 60
      origin_keepalive_timeout = 60
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.cloudfront_certificate_arn
    minimum_protocol_version = "TLSv1.1_2016"
    ssl_support_method       = "sni-only"
  }

  tags = {
    Name = "${var.namespace}_CloudFront_${var.environment}"
  }
}