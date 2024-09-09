variable "vpc_id" {
  description = "The VPC ID where the NAT Gateway will be deployed"
  type        = string
}

variable "public_subnet_id" {
  description = "The public subnet ID where NAT Gateway will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "nat_name" {
  description = "The name of the NAT Gateway"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  type        = string
}