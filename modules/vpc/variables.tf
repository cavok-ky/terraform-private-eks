variable "VPC_NAME" {
  description = "VPC name"
  type        = string
}

variable "VPC_CIDR_BLOCK" {
  description = "VPC cidr block"
  type        = string
}

variable "PUBLIC_SUBNET" {
  type = list(object({
    name              = string
    subnet_cidr       = string
    availability_zone = string
    map_public_ip     = bool
    })
  )
}

variable "PRIVATE_SUBNET" {
  type = list(object({
    name              = string
    subnet_cidr       = string
    availability_zone = string
    map_public_ip     = bool
    })
  )
}

variable "AWS_REGION" {
  description = "Target AWS region"
  type        = string
}
