variable "region" {
  description = "AWS Region"
  default     = "ap-northeast-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.1.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.1.3.0/24", "10.1.4.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "rds_instance_class" {
  description = "Instance class for RDS"
  default     = "db.t3.micro"
}

variable "rds_identifier" {
  description = "RDS instance identifier for prod"
  default     = "prod-rds"
}

variable "bastion_ami" {
  description = "AMI ID for Bastion host"
  default     = "ami-07d737d4d8119ad79"
}

variable "bastion_instance_type" {
  description = "Instance type for Bastion host"
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key pair name for SSH access"
  default     = "teamProject"
}

variable "alb_name" {
  description = "Name of the ALB"
  default     = "prod-alb"
}

variable "repository_name" {
  description = "Name of the ECR repository"
  default     = "prod-repo"
}
