############################################################
# VARIABLES
############################################################

variable "project_name" {
  default = "eks-demo"
}

variable "environment" {
  default = "dev"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "private_subnets" {
  default = [
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]
}

variable "availability_zones" {
  default = [
    "us-east-1a",
    "us-east-1b"
  ]
}

############################################################
# VPC
############################################################

resource "aws_vpc" "this" {

  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-${var.environment}-vpc"
  }
}

############################################################
# INTERNET GATEWAY
############################################################

resource "aws_internet_gateway" "this" {

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

############################################################
# PUBLIC SUBNETS
############################################################

resource "aws_subnet" "public" {

  count = length(var.public_subnets)

  vpc_id = aws_vpc.this.id

  cidr_block = var.public_subnets[count.index]

  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-${count.index+1}"

    "kubernetes.io/role/elb" = "1"
  }
}

############################################################
# PRIVATE SUBNETS
############################################################

resource "aws_subnet" "private" {

  count = length(var.private_subnets)

  vpc_id = aws_vpc.this.id

  cidr_block = var.private_subnets[count.index]

  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}-private-${count.index+1}"

    "kubernetes.io/role/internal-elb" = "1"
  }
}

############################################################
# ELASTIC IP
############################################################

resource "aws_eip" "nat" {

  domain = "vpc"

  depends_on = [
    aws_internet_gateway.this
  ]

  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}

############################################################
# NAT GATEWAY
############################################################

resource "aws_nat_gateway" "this" {

  allocation_id = aws_eip.nat.id

  subnet_id = aws_subnet.public[0].id

  depends_on = [
    aws_internet_gateway.this
  ]

  tags = {
    Name = "${var.project_name}-natgw"
  }
}

############################################################
# PUBLIC ROUTE TABLE
############################################################

resource "aws_route_table" "public" {

  vpc_id = aws_vpc.this.id

  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

############################################################
# PRIVATE ROUTE TABLE
############################################################

resource "aws_route_table" "private" {

  vpc_id = aws_vpc.this.id

  route {

    cidr_block = "0.0.0.0/0"

    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

############################################################
# PUBLIC ROUTE TABLE ASSOCIATION
############################################################

resource "aws_route_table_association" "public" {

  count = length(var.public_subnets)

  subnet_id = aws_subnet.public[count.index].id

  route_table_id = aws_route_table.public.id
}

############################################################
# PRIVATE ROUTE TABLE ASSOCIATION
############################################################

resource "aws_route_table_association" "private" {

  count = length(var.private_subnets)

  subnet_id = aws_subnet.private[count.index].id

  route_table_id = aws_route_table.private.id
}

############################################################
# EKS SECURITY GROUP
############################################################

resource "aws_security_group" "eks" {

  name = "${var.project_name}-eks-sg"

  description = "Security Group for EKS"

  vpc_id = aws_vpc.this.id

  ingress {

    description = "HTTPS"

    from_port = 443

    to_port = 443

    protocol = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  ingress {

    description = "Node Communication"

    from_port = 1025

    to_port = 65535

    protocol = "tcp"

    self = true
  }

  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "${var.project_name}-eks-sg"
  }
}

############################################################
# OUTPUTS
############################################################

output "vpc_id" {

  value = aws_vpc.this.id
}

output "public_subnets" {

  value = aws_subnet.public[*].id
}

output "private_subnets" {

  value = aws_subnet.private[*].id
}

output "security_group_id" {

  value = aws_security_group.eks.id
}
