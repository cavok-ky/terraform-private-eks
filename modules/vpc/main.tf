# VPC
resource "aws_vpc" "eks-vpc" {
  cidr_block = var.VPC_CIDR_BLOCK
  enable_dns_hostnames = false

  tags = {
    Name = "${var.VPC_NAME}"
  } 
}

# Internet Gateway
resource "aws_internet_gateway" "private-eks-igw" {
  vpc_id = aws_vpc.eks-vpc.id

  tags = {
    Name = "${var.VPC_NAME}-igw"
  }
}

# Public Subnets
resource "aws_subnet" "eks-public-subnet" {
  for_each             = { for subnet in var.PUBLIC_SUBNET : subnet.name => subnet }

  vpc_id                  = aws_vpc.eks-vpc.id
  cidr_block              = each.value.subnet_cidr
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip
  tags = {
    Name = each.key
  }
}

# Private Subnets
resource "aws_subnet" "eks-private-subnet" {
  for_each             = { for subnet in var.PRIVATE_SUBNET : subnet.name => subnet }

  vpc_id                  = aws_vpc.eks-vpc.id
  cidr_block              = each.value.subnet_cidr
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip
  tags = {
    Name = each.key
  }
}

# NAT Gateways
resource "aws_nat_gateway" "eks-nat" {
  count         = length(aws_subnet.eks-private-subnet)
  allocation_id = aws_eip.eks-eip[count.index].id
  subnet_id     = local.public_subnet_id[count.index]

  tags = {
    Name = "${var.VPC_NAME}-nat-${count.index}-${var.AWS_REGION}"
  }

  depends_on = [aws_internet_gateway.private-eks-igw]
}

# EIPs to be assigned to NAT Gateway
resource "aws_eip" "eks-eip" {
  count = length(aws_subnet.eks-private-subnet)
  tags = {
    Name = "${var.VPC_NAME}-eip-${count.index}-${var.AWS_REGION}"
  }
}

# Route table to map to private subnets
resource "aws_route_table" "private-subnet-rtb" {
  count  = length(aws_subnet.eks-private-subnet)
  
  vpc_id = aws_vpc.eks-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks-nat[count.index].id
  }

  tags = {
    Name = "private-subnet-rtb-${count.index}-${var.AWS_REGION}"
  }
}

# Route table to map to public subnet
resource "aws_route_table" "public-subnet-rtb" {
  vpc_id = aws_vpc.eks-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.private-eks-igw.id
  }

  tags = {
    Name = "public-subnet-rtb-${var.AWS_REGION}"
  }
}

# Private subnet and route table association
resource "aws_route_table_association" "private-subnet-rtb-assoc" {
  count = length(aws_subnet.eks-private-subnet)

  subnet_id      = local.private_subnet_id[count.index]
  route_table_id = data.aws_route_table.private-rtb[count.index].id
}

# Public subnet and route table association
resource "aws_route_table_association" "public-subnet-rtb-assoc-0" {
  count = length(aws_subnet.eks-public-subnet)

  subnet_id      = local.public_subnet_id[count.index]
  route_table_id = data.aws_route_table.public-rtb.id
}

# Data sources of public route tables
data "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.eks-vpc.id

  filter {
    name = "tag:Name"
    values = ["public*"]
  }

  depends_on = [aws_route_table.public-subnet-rtb]
}

# Data sources of private route tables
data "aws_route_table" "private-rtb" {
  count = length(aws_subnet.eks-private-subnet)
  vpc_id = aws_vpc.eks-vpc.id

  filter {
    name = "tag:Name"
    values = ["private*${count.index}*"]
  }

  depends_on = [aws_route_table.private-subnet-rtb]
}

# Data sources of public subnet ids
data "aws_subnet_ids" "public_subnet_ids" {
  vpc_id = aws_vpc.eks-vpc.id

  filter {
    name = "tag:Name"
    values = ["*public*"]
  }

  depends_on = [aws_subnet.eks-public-subnet]
}

# Data sources of private subnet ids
data "aws_subnet_ids" "private_subnet_ids" {
  vpc_id = aws_vpc.eks-vpc.id

  filter {
    name = "tag:Name"
    values = ["*private*"]
  }

  depends_on = [aws_subnet.eks-private-subnet]
}

# Setting data sources of public subnet ids as a local variable
locals {
  public_subnet_id = tolist(data.aws_subnet_ids.public_subnet_ids.ids)
}

# Setting data sources of private subnet ids as a local variable
locals {
  private_subnet_id = tolist(data.aws_subnet_ids.private_subnet_ids.ids)
}