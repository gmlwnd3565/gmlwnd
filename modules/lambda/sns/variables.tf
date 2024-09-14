variable "topic_name" {
  type        = string
  description = "The name of the SNS topic."
}

variable "lambda_function_arn" {
  type        = string
  description = "The ARN of the Lambda function that will process the SNS messages."
}
