variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "dynamodb_table" {
  description = "The name of the DynamoDB table used for state locking."
  type        = string
}
