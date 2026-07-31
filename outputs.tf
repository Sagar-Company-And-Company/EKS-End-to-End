output "project_name" {
  value = local.project_name
}

output "environment" {
  value = local.environment
}

# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

# Subnet Outputs
output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

# EKS Outputs
output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.main.id
}

output "eks_cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.main.arn
}

output "eks_cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "eks_cluster_version" {
  description = "EKS cluster version"
  value       = aws_eks_cluster.main.version
}

output "eks_cluster_security_group_id" {
  description = "EKS cluster security group ID"
  value       = aws_security_group.eks_cluster.id
}

output "eks_node_group_id" {
  description = "EKS node group ID"
  value       = aws_eks_node_group.main.id
}

# ECR Outputs
output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.main.repository_url
}

output "ecr_repository_arn" {
  description = "ECR repository ARN"
  value       = aws_ecr_repository.main.arn
}

# IAM Outputs
output "eks_cluster_role_arn" {
  description = "EKS cluster role ARN"
  value       = aws_iam_role.eks_cluster.arn
}

output "eks_node_role_arn" {
  description = "EKS node role ARN"
  value       = aws_iam_role.eks_nodes.arn
}

# S3 Outputs
output "app_logs_bucket_name" {
  description = "S3 bucket for application logs"
  value       = aws_s3_bucket.app_logs.id
}

output "app_logs_bucket_arn" {
  description = "S3 bucket ARN for application logs"
  value       = aws_s3_bucket.app_logs.arn
}

# DynamoDB Outputs
output "app_state_table_name" {
  description = "DynamoDB table for application state"
  value       = aws_dynamodb_table.app_state.name
}

output "app_state_table_arn" {
  description = "DynamoDB table ARN for application state"
  value       = aws_dynamodb_table.app_state.arn
}

output "app_config_table_name" {
  description = "DynamoDB table for application configuration"
  value       = aws_dynamodb_table.app_config.name
}

output "app_config_table_arn" {
  description = "DynamoDB table ARN for application configuration"
  value       = aws_dynamodb_table.app_config.arn
}

# Kubectl Configuration
output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
}