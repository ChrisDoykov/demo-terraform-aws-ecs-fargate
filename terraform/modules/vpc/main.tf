terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_vpc" "default" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.namespace}_VPC_${var.environment}"
  }
}

# Create an Internet Gateway instance for egress/ingress connections to resources in the public subnets

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "${var.namespace}_InternetGateway_${var.environment}"
  }
}

# This resource returns a list of all AZs available in the region configured in the AWS credentials

data "aws_availability_zones" "available" {}