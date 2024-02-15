# terraform-private-eks/main.tf

# VPC module
module "eks-vpc-subnet" {
  source = "./modules/vpc"
  
  AWS_REGION = var.AWS_REGION
  VPC_NAME   = "${var.CLUSTER_NAME}-vpc"
  VPC_CIDR_BLOCK = "10.10.0.0/16" 

  PUBLIC_SUBNET = [
    {
      name              = "eks-subnet-public-ap-northeast-2a"
      subnet_cidr       = "10.10.1.0/24"
      availability_zone = "ap-northeast-2a"
      map_public_ip     = true
    },
    {
      name              = "eks-subnet-public-ap-northeast-2c"
      subnet_cidr       = "10.10.3.0/24"
      availability_zone = "ap-northeast-2c"
      map_public_ip     = true
    }
  ]
  
  PRIVATE_SUBNET = [
    {
      name              = "eks-subnet-private-ap-northeast-2a"
      subnet_cidr       = "10.10.2.0/24"
      availability_zone = "ap-northeast-2a"
      map_public_ip     = false
    },
    {
      name              = "eks-subnet-private-ap-northeast-2c"
      subnet_cidr       = "10.10.4.0/24"
      availability_zone = "ap-northeast-2c"
      map_public_ip     = false
    }
  ]
}

# EC2 module - bastion
module "bastion" {
  source = "./modules/ec2"
  
  EC2_NAME            = "bastion"
  AMI                 = "ami-0e735aba742568824"
  INSTANCE_TYPE       = "t2.medium"
  KEY_PAIR_NAME       = data.aws_key_pair.key-seoul.key_name
  ASSOCIATE_PUBLIC_IP = true
  VPC_ID              = module.eks-vpc-subnet.vpc-id
  SUBNET_ID           = local.public_subnet_id[0]
  LOCAL_HOST_CIDR     = local.local_host_cidr
}

# EC2 module - jenkins-server
module "jenkins-server" {
  source = "./modules/ec2"
  
  EC2_NAME            = "jenkins-server"
  AMI                 = "ami-0e735aba742568824"
  INSTANCE_TYPE       = "t2.medium"
  KEY_PAIR_NAME       = data.aws_key_pair.key-seoul.key_name
  ASSOCIATE_PUBLIC_IP = true
  VPC_ID              = module.eks-vpc-subnet.vpc-id
  SUBNET_ID           = local.public_subnet_id[1]
  LOCAL_HOST_CIDR     = local.local_host_cidr
}

# eks-cluster module
module "eks-cluster" {
  source = "./modules/eks-cluster"
  
  CLUSTER_NAME       = var.CLUSTER_NAME
  PRIVATE_ACCESS     = true
  PUBLIC_ACCESS      = false
  EKS_SUBNET_ID      = local.private_subnet_id[*]
  BASTION_SG_ID      = module.bastion.bastion-sg-id

  depends_on = [module.eks-vpc-subnet]
}

# eks-node module
module "eks-node" {
  source = "./modules/eks-node"

  CLUSTER_NAME       = var.CLUSTER_NAME
  EKS_SUBNET_ID      = local.private_subnet_id[*]
  INSTANCE_TYPE      = "t2.medium"
  NODE_KEY_PAIR      = data.aws_key_pair.key-seoul.key_name
  BASTION_SG_ID      = module.bastion.bastion-sg-id

  depends_on = [module.eks-cluster]
}

# Getting my local IP to allow ssh in the security group
data "http" "local_host_ip" {
  url = "http://ipv4.icanhazip.com"
}

# Data sources of key pair
data "aws_key_pair" "key-seoul" {
  key_name           = "key-seoul"
}

# Data sources of public subnet ids
data "aws_subnet_ids" "public_subnet_ids" {
  vpc_id = module.eks-vpc-subnet.vpc-id

  filter {
    name = "tag:Name"
    values = ["*public*"]
  }

  depends_on = [module.eks-vpc-subnet.eks-public-subnet]
}

# Data sources of private subnet ids
data "aws_subnet_ids" "private_subnet_ids" {
  vpc_id = module.eks-vpc-subnet.vpc-id

  filter {
    name = "tag:Name"
    values = ["*private*"]
  }

  depends_on = [module.eks-vpc-subnet.eks-private-subnet]
}

# Setting my local IP ids as a local variable
locals {
  local_host_cidr = "${chomp(data.http.local_host_ip.response_body)}/32"
}

# Setting public subnet ids as a local variable
locals {
  public_subnet_id = tolist(data.aws_subnet_ids.public_subnet_ids.ids)
}

# Setting private subnet ids as a local variable
locals {
  private_subnet_id = tolist(data.aws_subnet_ids.private_subnet_ids.ids)
}