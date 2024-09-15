variable "aws_region" {
  description = "AWS Region for development environment"
  default     = "ap-northeast-2"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "VPC Name"
  default     = "my-vpc"
}