# EKS Cluster Security Group
resource "aws_security_group" "eks_cluster" {
  name        = "${local.project_name}-eks-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-eks-cluster-sg"
    }
  )
}

# Allow inbound traffic from nodes
resource "aws_security_group_rule" "eks_cluster_ingress_workstation_https" {
  description       = "Allow workstation to communicate with the cluster API"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_cluster.id
  to_port           = 443
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Allow all outbound traffic
resource "aws_security_group_rule" "eks_cluster_egress" {
  description       = "Allow all outbound traffic"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.eks_cluster.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

# EKS Node Security Group
resource "aws_security_group" "eks_nodes" {
  name        = "${local.project_name}-eks-nodes-sg"
  description = "Security group for EKS nodes"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-eks-nodes-sg"
    }
  )
}

# Allow nodes to communicate with the cluster API
resource "aws_security_group_rule" "eks_nodes_ingress_cluster" {
  description              = "Allow nodes to communicate with the cluster API"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes.id
  to_port                  = 65535
  type                     = "ingress"
  source_security_group_id = aws_security_group.eks_cluster.id
}

# Allow node to node communication
resource "aws_security_group_rule" "eks_nodes_ingress_self" {
  description       = "Allow nodes to communicate with each other"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.eks_nodes.id
  to_port           = 65535
  type              = "ingress"
  self              = true
}

# Allow nodes to reach cluster API
resource "aws_security_group_rule" "eks_nodes_ingress_cluster_https" {
  description              = "Allow nodes to reach the cluster API"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes.id
  to_port                  = 443
  type                     = "ingress"
  source_security_group_id = aws_security_group.eks_cluster.id
}

# Allow all outbound traffic
resource "aws_security_group_rule" "eks_nodes_egress" {
  description       = "Allow all outbound traffic"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.eks_nodes.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Allow cluster security group to ingress from nodes on all ports
resource "aws_security_group_rule" "eks_cluster_ingress_nodes" {
  description              = "Allow nodes to communicate with the cluster API"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_cluster.id
  to_port                  = 65535
  type                     = "ingress"
  source_security_group_id = aws_security_group.eks_nodes.id
}
