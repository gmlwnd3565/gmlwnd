# variables.tf
variable "region" {
  description = "AWS region"
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

variable "allowed_ssh_cidr" {
  description = "Allowed CIDR block for SSH access"
  default     = "0.0.0.0/0"  # 일반적으로 본인의 IP로 제한하는 것이 안전합니다.
}
