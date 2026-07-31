#############################################################
# VARIABLES
#############################################################

variable "cluster_name" {
  default = "eks-demo"
}

variable "cluster_version" {
  default = "1.33"
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "cluster_role_arn" {
  type = string
}

variable "node_role_arn" {
  type = string
}

variable "security_group_id" {
  type = string
}

#############################################################
# EKS CLUSTER
#############################################################

resource "aws_eks_cluster" "eks" {

  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.cluster_version

  vpc_config {

    subnet_ids = var.private_subnet_ids

    security_group_ids = [
      var.security_group_id
    ]

    endpoint_private_access = true

    endpoint_public_access = true
  }

  access_config {

    authentication_mode = "API_AND_CONFIG_MAP"

    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [
    var.cluster_role_arn
  ]

  tags = {
    Name = var.cluster_name
  }
}

#############################################################
# DATA SOURCES
#############################################################

data "aws_eks_cluster" "cluster" {

  name = aws_eks_cluster.eks.name
}

data "aws_eks_cluster_auth" "cluster" {

  name = aws_eks_cluster.eks.name
}

#############################################################
# EKS MANAGED NODE GROUP
#############################################################

resource "aws_eks_node_group" "workers" {

  cluster_name    = aws_eks_cluster.eks.name

  node_group_name = "${var.cluster_name}-node-group"

  node_role_arn   = var.node_role_arn

  subnet_ids      = var.private_subnet_ids

  ami_type        = "AL2023_x86_64_STANDARD"

  capacity_type   = "ON_DEMAND"

  instance_types  = ["t3.medium"]

  disk_size       = 20

  scaling_config {

    desired_size = 2

    min_size = 2

    max_size = 4
  }

  update_config {

    max_unavailable = 1
  }

  labels = {

    Environment = "dev"

    NodeGroup = "workers"
  }

  tags = {

    Name = "${var.cluster_name}-worker-node"

    Environment = "dev"
  }

  depends_on = [

    aws_eks_cluster.eks
  ]
}

#############################################################
# COREDNS ADDON
#############################################################

resource "aws_eks_addon" "coredns" {

  cluster_name = aws_eks_cluster.eks.name

  addon_name = "coredns"

  resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [
    aws_eks_node_group.workers
  ]
}

#############################################################
# KUBE-PROXY ADDON
#############################################################

resource "aws_eks_addon" "kube_proxy" {

  cluster_name = aws_eks_cluster.eks.name

  addon_name = "kube-proxy"

  resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [
    aws_eks_node_group.workers
  ]
}

#############################################################
# VPC CNI ADDON
#############################################################

resource "aws_eks_addon" "vpc_cni" {

  cluster_name = aws_eks_cluster.eks.name

  addon_name = "vpc-cni"

  resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [
    aws_eks_node_group.workers
  ]
}

#############################################################
# EBS CSI DRIVER
#############################################################

resource "aws_eks_addon" "ebs_csi" {

  cluster_name = aws_eks_cluster.eks.name

  addon_name = "aws-ebs-csi-driver"

  resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [
    aws_eks_node_group.workers
  ]
}

#############################################################
# OUTPUTS
#############################################################

output "cluster_name" {
  value = aws_eks_cluster.eks.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "cluster_certificate" {
  value = aws_eks_cluster.eks.certificate_authority[0].data
}

output "cluster_arn" {
  value = aws_eks_cluster.eks.arn
}

output "node_group_name" {
  value = aws_eks_node_group.workers.node_group_name
}
