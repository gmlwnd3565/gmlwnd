variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "dynamodb_table" {
  description = "The name of the DynamoDB table used for state locking."
  type        = string
}

variable "create_dynamodb_table" {
  description = "Whether to create a new DynamoDB table or not"
  type        = bool
  default     = false  # 기본적으로 테이블을 생성하지 않도록 설정
}
