output "vpc-id" {
    value = aws_vpc.eks-vpc.id
}

output "eks-public-subnet" {
    value = aws_subnet.eks-public-subnet
}

output "eks-private-subnet" {
    value = aws_subnet.eks-private-subnet
}