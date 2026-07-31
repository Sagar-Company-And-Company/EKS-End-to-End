# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name                                           = "${local.project_name}-public-subnet-${count.index + 1}"
      "kubernetes.io/role/elb"                       = "1"
      "kubernetes.io/cluster/${local.project_name}" = "shared"
    }
  )
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    local.common_tags,
    {
      Name                                            = "${local.project_name}-private-subnet-${count.index + 1}"
      "kubernetes.io/role/internal-elb"              = "1"
      "kubernetes.io/cluster/${local.project_name}"  = "shared"
    }
  )
}
