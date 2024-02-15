variable "CLUSTER_NAME" {
  description = "Cluster Name"
  type        = string
}

variable "PRIVATE_ACCESS" {
  description = "Allow private access"
  type        = bool
}

variable "PUBLIC_ACCESS" {
  description = "Allow public access"
  type        = bool
}

variable "EKS_SUBNET_ID" {
  description = "EKS subnet ID"
  type        = list(string) 
}

variable "BASTION_SG_ID" {
  description = "Bastion security group to allow remote access"
  type        = string
}
