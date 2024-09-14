# 중복된 선언을 제거한 예시

variable "instance_class" {
  description = "The instance class for the RDS instance"
  type        = string
}

variable "db_name" {
  description = "The name of the database"
  type        = string
}

variable "username" {
  description = "The username for the database"
  type        = string
}

variable "password" {
  description = "The password for the database"
  type        = string
}

variable "subnet_group" {
  description = "The DB subnet group name or IDs"
  type        = list(string)  # 리스트로 할지, 단일 문자열로 할지는 상황에 맞게 설정
}

variable "security_group_id" {
  description = "The security group ID for the RDS instance"
  type        = string
}
