output "vpc_id" {
  value       = aws_vpc.default.id
  description = "The ID of the VPC resource"
}
output "public_subnets" {
  value       = [for subnet in aws_subnet.public : subnet.id]
  description = "The IDs of the public subnets"
}
output "private_subnets" {
  value       = [for subnet in aws_subnet.private : subnet.id]
  description = "The IDs of the private subnets"
}