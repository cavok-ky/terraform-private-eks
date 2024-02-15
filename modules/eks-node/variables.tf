variable "CLUSTER_NAME" {
  description = "Cluster Name"
  type        = string
}

variable "EKS_SUBNET_ID" {
  description = "EKS subnet ID"
  type        = list(string) 
}

variable "INSTANCE_TYPE" {
  description = "Worker node instance type"
  type        = string
  default     = "t2.medium"
}

variable "NODE_KEY_PAIR" {
  description = "Worker node key pair"
  type        = string
}

variable "BASTION_SG_ID" {
  description = "Bastion security group to allow remote access"
  type        = string
}
