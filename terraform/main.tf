terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {} # Configuration provided using a .conf file (locally) and terraform init -backend-config= (in CI/CD)
}

module "cloudfront" {
  source = "./modules/cloudfront"
  providers = {
    aws = aws.main
  }
  namespace                       = var.namespace
  environment                     = var.environment
  custom_origin_host_header_value = var.custom_origin_host_header_value
  domain_name                     = var.domain_name
  alb_name                        = module.ecs.alb_name
  alb_dns_name                    = module.ecs.alb_dns_name
  cloudfront_certificate_arn      = module.ecs.cloudfront_certificate_arn
}

module "r53" {
  source = "./modules/r53"
  providers = {
    aws = aws.main
  }
  domain_name                            = var.domain_name
  environment                            = var.environment
  tld_zone_id                            = var.tld_zone_id
  service_name                           = var.service_name
  cloudfront_distribution_domain_name    = module.cloudfront.cloudfront_distribution_domain_name
  cloudfront_distribution_hosted_zone_id = module.cloudfront.cloudfront_distribution_hosted_zone_id
}

module "vpc" {
  source = "./modules/vpc"
  providers = {
    aws = aws.main
  }
  vpc_cidr_block = var.vpc_cidr_block
  environment    = var.environment
  namespace      = var.namespace
  az_count       = var.az_count
}

module "ecr" {
  source = "./modules/ecr"
  providers = {
    aws = aws.main
  }
  namespace        = var.namespace
  service_name     = var.service_name
  ecr_force_delete = var.ecr_force_delete
  environment      = var.environment
}

module "ecs" {
  source = "./modules/ecs"
  providers = {
    aws.main      = aws.main
    aws.us_east_1 = aws.us_east_1
  }
  domain_name                                 = var.domain_name
  environment                                 = var.environment
  namespace                                   = var.namespace
  ecs_task_desired_count                      = var.ecs_task_desired_count
  ecs_task_deployment_minimum_healthy_percent = var.ecs_task_deployment_minimum_healthy_percent
  ecs_task_deployment_maximum_percent         = var.ecs_task_deployment_maximum_percent
  service_name                                = var.service_name
  container_port                              = var.container_port
  cpu_units                                   = var.cpu_units
  memory                                      = var.memory
  image_version                               = var.image_version
  repo_url                                    = module.ecr.ecr_repo_url
  log_retention_in_days                       = var.log_retention_in_days
  region                                      = var.region
  custom_origin_host_header_value             = var.custom_origin_host_header_value
  healthcheck_matcher                         = var.healthcheck_matcher
  healthcheck_endpoint                        = var.healthcheck_endpoint
  vpc_id                                      = module.vpc.vpc_id
  r53_zone_id                                 = module.r53.r53_zone_id
  public_subnets                              = module.vpc.public_subnets
  private_subnets                             = module.vpc.private_subnets
  ecs_task_min_count                          = var.ecs_task_min_count
  ecs_task_max_count                          = var.ecs_task_max_count
  cpu_target_tracking_desired_value           = var.cpu_target_tracking_desired_value
  memory_target_tracking_desired_value        = var.memory_target_tracking_desired_value
}