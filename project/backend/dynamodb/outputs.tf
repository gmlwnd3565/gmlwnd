output "dynamodb_table_name" {
  value       = aws_dynamodb_table.ssoon_dynamodbtable.name
  description = "The name of the DynamoDB table"
}