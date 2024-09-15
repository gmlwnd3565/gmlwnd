output "lambda_function_arn" {
  description = "The ARN of the Lambda function."
  value       = aws_lambda_function.lambda_function.arn
}

output "sqs_queue_arn" {
  description = "The ARN of the SQS queue."
  value       = module.sqs.sqs_queue_arn
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic."
  value       = module.sns.sns_topic_arn
}

output "cloudwatch_log_group_name" {
  value = module.cloudwatch.log_group_name
}