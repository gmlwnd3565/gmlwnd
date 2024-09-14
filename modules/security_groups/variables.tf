variable "name" {
  description = "Name of the security group"
  type        = string
}

variable "ingress_port" {
  description = "The ingress port"
  type        = list(number)
}

variable "protocol" {
  description = "The protocol for the ingress rule"
  type        = string
  default     = "tcp"
}

variable "cidr_blocks" {
  description = "Allowed CIDR blocks for the ingress rule"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for the security group"
  type        = string
}
