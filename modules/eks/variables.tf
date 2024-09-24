variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "EKS Cluster version"
  type        = string
  default     = "1.21"
}

variable "subnet_ids" {
  description = "Subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "iam_role_name" {
  description = "Name for the IAM role for EKS"
  type        = string
}

variable "desired_capacity" {
  description = "Desired capacity of the EKS worker nodes"
  type        = number
}

variable "max_capacity" {
  description = "Maximum capacity of the EKS worker nodes"
  type        = number
}

variable "min_capacity" {
  description = "Minimum capacity of the EKS worker nodes"
  type        = number
}

variable "instance_type" {
  description = "EC2 instance type for the EKS worker nodes"
  type        = string
  default     = "t3.medium"
}
