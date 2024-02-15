output "r53_zone_id" {
  value       = data.external.get_r53_zone.result.id
  description = "The ID of the Route53 zone"
}
