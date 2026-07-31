# EKS Cluster
resource "aws_eks_cluster" "main" {
  name            = "${local.project_name}-eks"
  version         = "1.28"
  role_arn        = aws_iam_role.eks_cluster.arn
  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  vpc_config {
    subnet_ids              = concat(aws_subnet.public[*].id, aws_subnet.private[*].id)
    security_group_ids      = [aws_security_group.eks_cluster.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-eks"
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_cni_policy,
    aws_cloudwatch_log_group.eks_cluster
  ]
}

# CloudWatch Log Group for EKS Cluster
resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${local.project_name}/cluster"
  retention_in_days = 7

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-eks-logs"
    }
  )
}

# EKS Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${local.project_name}-node-group"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = aws_subnet.private[*].id
  version         = aws_eks_cluster.main.version

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  instance_types = ["t3.medium"]

  disk_size = 30

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-node-group"
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_registry_policy,
    aws_iam_role_policy_attachment.eks_cloudwatch_logs
  ]
}

# EBS CSI Driver Add-on
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = aws_eks_cluster.main.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.24.0-eksbuild.1"
  service_account_role_arn = aws_iam_role.ebs_csi_driver.arn

  tags = local.common_tags
}

# VPC CNI Add-on
resource "aws_eks_addon" "vpc_cni" {
  cluster_name             = aws_eks_cluster.main.name
  addon_name               = "vpc-cni"
  addon_version            = "v1.14.1-eksbuild.1"
  service_account_role_arn = aws_iam_role.eks_nodes.arn

  tags = local.common_tags
}

# CoreDNS Add-on
resource "aws_eks_addon" "coredns" {
  cluster_name   = aws_eks_cluster.main.name
  addon_name     = "coredns"
  addon_version  = "v1.9.3-eksbuild.2"

  tags = local.common_tags
}

# kube-proxy Add-on
resource "aws_eks_addon" "kube_proxy" {
  cluster_name   = aws_eks_cluster.main.name
  addon_name     = "kube-proxy"
  addon_version  = "v1.28.1-eksbuild.1"

  tags = local.common_tags
}
