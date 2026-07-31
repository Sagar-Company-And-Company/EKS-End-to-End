##########################################################
# VARIABLES
##########################################################

variable "project_name" {
  default = "eks-demo"
}

##########################################################
# EKS CLUSTER IAM ROLE
##########################################################

resource "aws_iam_role" "eks_cluster_role" {

  name = "${var.project_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "eks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-cluster-role"
  }
}

##########################################################
# ATTACH CLUSTER POLICIES
##########################################################

resource "aws_iam_role_policy_attachment" "cluster_policy" {

  role = aws_iam_role.eks_cluster_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "vpc_controller" {

  role = aws_iam_role.eks_cluster_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

##########################################################
# NODE GROUP IAM ROLE
##########################################################

resource "aws_iam_role" "node_group_role" {

  name = "${var.project_name}-node-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Principal = {

          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-node-role"
  }
}

##########################################################
# NODE GROUP POLICIES
##########################################################

resource "aws_iam_role_policy_attachment" "worker_node" {

  role = aws_iam_role.node_group_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cni" {

  role = aws_iam_role.node_group_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr" {

  role = aws_iam_role.node_group_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

##########################################################
# OPTIONAL
# SSM ACCESS TO EC2 NODES
##########################################################

resource "aws_iam_role_policy_attachment" "ssm" {

  role = aws_iam_role.node_group_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

##########################################################
# OUTPUTS
##########################################################

output "cluster_role_arn" {

  value = aws_iam_role.eks_cluster_role.arn
}

output "node_role_arn" {

  value = aws_iam_role.node_group_role.arn
}
