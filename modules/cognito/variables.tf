variable "user_pool_name" {
  description = "The name of the Cognito User Pool"
  type        = string
}

variable "cognito_to_rds_function_arn" {
  type = string
}