output "bucket_name" {
  value = aws_s3_bucket.soon_s3bucket # S3 리소스에서 bucket 이름을 출력
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.soon_s3bucket.arn
  description = "The ARN of the S3 bucket"
}

output "dynamodb_table" {
  value       = aws_dynamodb_table.ssoon_dynamodbtable.name
  description = "The name of the DynamoDB table"
}

