output "api_gateway_url" {
  value       = module.api.api_gateway_url
  description = "The URL of the API Gateway."
}

output "lambda_function_arn" {
  value       = module.lambda.lambda_function_arn
  description = "The ARN of the Lambda function."
}

output "cloudwatch_log_group_name" {
  value = module.lambda.cloudwatch_log_group_name
}

output "sqs_queue_arn" {
  value = module.lambda.sqs_queue_arn
}

output "sns_topic_arn" {
  value = module.lambda.sns_topic_arn
}
