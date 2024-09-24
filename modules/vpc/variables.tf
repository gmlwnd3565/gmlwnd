variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
}

variable "name" {
  description = "Name tag for the VPC"
  type        = string
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

# variable "transit_gateway_id" {
#   description = "Transit Gateway의 ID"
#   type        = string
# }

# variable "dev_vpc_cidr" {
#   description = "개발 VPC의 CIDR 블록"
#   type        = string
# }

# variable "prod_vpc_cidr" {
#   description = "프로덕션 VPC의 CIDR 블록"
#   type        = string
# }
