variable "api_name" {
  type        = string
  description = "The name of the API Gateway."
}

variable "api_stage_name" {
  type        = string
  description = "The stage name for the API Gateway."
}

variable "lambda_arn" {
  type        = string
  description = "The ARN of the Lambda function."
}
