variable "aws_region" {
  description = "AWS Region for development environment"
  default     = "ap-northeast-2"
}

variable "instance_identifier" {
  type        = string
  description = "The identifier for the RDS instance"
  default     = "dev-rds-instance"  # 원하는 값으로 설정
}
