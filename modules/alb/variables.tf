variable "alb_name" {
  description = "The name of the Application Load Balancer"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnets for the ALB"
  type        = list(string)
}

variable "security_groups" {
  description = "Security groups to assign to the ALB"
  type        = list(string)
}

