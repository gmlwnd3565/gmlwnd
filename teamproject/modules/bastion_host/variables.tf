variable "bastion_ami" {
  description = "AMI ID for the Bastion Host"
  type        = string
}

variable "bastion_instance_type" {
  description = "Instance type for the Bastion Host"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for the Bastion Host"
  type        = string
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
}
