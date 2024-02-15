# IAM role for EKS cluster
resource "aws_iam_role" "eks-cluster-role" {
  name = "${var.CLUSTER_NAME}-cluster-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# IAM EKS cluster role & policy(AmazonEKSClusterPolicy) attachment
resource "aws_iam_role_policy_attachment" "eks-cluster-role-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-role.name
}

# EKS cluster
resource "aws_eks_cluster" "private-eks" {
  name     = var.CLUSTER_NAME
  role_arn = aws_iam_role.eks-cluster-role.arn
  vpc_config {
    endpoint_private_access   = var.PRIVATE_ACCESS
    endpoint_public_access    = var.PUBLIC_ACCESS
    subnet_ids                = var.EKS_SUBNET_ID
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-role-AmazonEKSClusterPolicy
  ]
}

# Adding a security group rule to EKS cluster security group
resource "aws_security_group_rule" "allow-bastion" {
  type                     = "ingress"
  to_port                  = 443
  protocol                 = "tcp"
  from_port                = 443
  source_security_group_id = var.BASTION_SG_ID
  security_group_id        = aws_eks_cluster.private-eks.vpc_config[0].cluster_security_group_id
}
