variable "queue_name" {
  type        = string
  description = "The name of the SQS queue."
}

variable "lambda_function_arn" {
  type        = string
  description = "The ARN of the Lambda function that will process the SQS messages."
}
