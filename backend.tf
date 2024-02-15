terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  # backend "s3" {

  #   bucket         = "cavok-private-eks-tfstate"
  #   key            = "private-eks/terraform.tfstate"
  #   region         = "ap-northeast-2"
  #   dynamodb_table = "terraform-locks"
  #   encrypt        = true

  # }
}

# resource "aws_s3_bucket" "tfstate" {
#   bucket = "${var.MY_IDENTIFIER}-${var.CLUSTER_NAME}-tfstate"
#   force_destroy = false
# }

# resource "aws_s3_bucket_versioning" "s3-versioning" {
#   bucket = aws_s3_bucket.tfstate.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "s3-server-encrypt" {
#   bucket = aws_s3_bucket.tfstate.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

# resource "aws_dynamodb_table" "terraform-locks" {
#   name         = "terraform-locks"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }