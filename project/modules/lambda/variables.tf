variable "lambda_function_name" {
  type        = string
  description = "The name of the Lambda function."
}

variable "lambda_zip_file" {
  type        = string
  description = "The path to the Lambda zip file."
}

variable "lambda_env" {
  type        = string
  description = "Environment for the Lambda function."
}

variable "sqs_queue_name" {
  type        = string
  description = "The name of the SQS queue."
}

variable "sns_topic_name" {
  type        = string
  description = "The name of the SNS topic."
}

variable "lambda_sqs_policy" {
  type = string
  default = "The name of SQS Policy Name"
}