variable "AMI" {
  description = "EC2 instance AMI"
  type        = string
  default     = "ami-0e735aba742568824"
}

variable "INSTANCE_TYPE" {
  description = "EC2 instance type"
  type        = string
}

variable "KEY_PAIR_NAME" {
  description = "Subnet cidr block"
  type        = string
}

variable "ASSOCIATE_PUBLIC_IP" {
  description = "Associating public IP to instance"
  type        = bool
}

variable "VPC_ID" {
  description = "VPC ID"
  type        = string 
}

variable "SUBNET_ID" {
  description = "Subnet ID"
  type        = string
}

variable "EC2_NAME" {
  description = "EC2 name"
  type        = string
}

variable "LOCAL_HOST_CIDR" {
  description = "Local host cidr"
  type        = string 
}
