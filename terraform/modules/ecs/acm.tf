# Certificate for Application Load Balancer including validation via CNAME record

resource "aws_acm_certificate" "alb_certificate" {
  provider                  = aws.main
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_route53_record" "alb_certificate_record" {
  for_each = {
    for dvo in aws_acm_certificate.alb_certificate.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = var.r53_zone_id
    }
  }

  provider        = aws.main
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

# Certificate for CloudFront Distribution in region us-east-1
# MUST be in us_east_1 (Cloudfront requirement)

resource "aws_acm_certificate" "cloudfront_certificate" {
  provider                  = aws.us_east_1
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# We only need one validation because DNS records are shared between zones

resource "aws_acm_certificate_validation" "alb_certificate_validation" {
  provider                = aws.main
  certificate_arn         = aws_acm_certificate.alb_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.alb_certificate_record : record.fqdn]
}
