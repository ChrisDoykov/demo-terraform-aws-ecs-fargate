output "cloudfront_distribution_domain_name" {
  value = aws_cloudfront_distribution.default.domain_name
}
output "cloudfront_distribution_hosted_zone_id" {
  value = aws_cloudfront_distribution.default.hosted_zone_id
}
