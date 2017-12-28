variable "aws_account_id" {}

variable "region" {}

variable "resource_name" {
  default = "ex-aws-batch"
}

variable "s3_bucket_name" {
  default = "ex-aws-batch"
}

variable "cidr" {
  default = "10.30.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.30.1.0/24"
}
