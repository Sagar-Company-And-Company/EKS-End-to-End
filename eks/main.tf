##########################################################
# VPC MODULE
##########################################################

module "vpc" {

  source = "../modules/vpc"

  project_name = var.project_name

  environment = var.environment

  vpc_cidr = var.vpc_cidr

  public_subnets = var.public_subnets

  private_subnets = var.private_subnets

  availability_zones = var.availability_zones
}

##########################################################
# IAM MODULE
##########################################################

module "iam" {

  source = "../modules/iam"

  project_name = var.project_name
}

##########################################################
# EKS MODULE
##########################################################

module "eks" {

  source = "../modules/eks"

  cluster_name = var.cluster_name

  cluster_version = var.cluster_version

  private_subnet_ids = module.vpc.private_subnets

  security_group_id = module.vpc.security_group_id

  cluster_role_arn = module.iam.cluster_role_arn

  node_role_arn = module.iam.node_role_arn
}

##########################################################
# OUTPUTS
##########################################################

output "cluster_name" {

  value = module.eks.cluster_name
}

output "cluster_endpoint" {

  value = module.eks.cluster_endpoint
}

output "vpc_id" {

  value = module.vpc.vpc_id
}
