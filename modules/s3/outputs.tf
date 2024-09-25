output "bucket_name" {
  value = aws_s3_bucket.soon_s3bucket # S3 리소스에서 bucket 이름을 출력
}

output "dynamodb_table" {
  value       = aws_dynamodb_table.ssoon_dynamodbtable.name
  description = "The name of the DynamoDB table"
}

output "tf_dynamodb_table" {
  value       = aws_dynamodb_table.tfstate_dynamodbtable.name
  description = "The name of the DynamoDB table"
}