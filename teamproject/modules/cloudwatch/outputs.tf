# modules/lambda/cloudwatch/outputs.tf
output "log_group_name" {
  value = aws_cloudwatch_log_group.log_group.name
}