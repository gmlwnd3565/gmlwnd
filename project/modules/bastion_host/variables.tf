variable "ami_id" {
  description = "The AMI ID for the Bastion host"
  type        = string
}

variable "subnet_id" {
  description = "The Subnet ID to launch the Bastion host"
  type        = string
}

variable "key_name" {
  description = "The SSH key name for the Bastion host"
  type        = string
}

variable "security_group_id" {
  description = "The security group ID for the Bastion host"
  type        = string
}
