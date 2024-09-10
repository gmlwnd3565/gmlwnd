output "s3_bucket_arn" {
  value       = aws_s3_bucket.soon_s3bucket.arn
  description = "The ARN of the S3 bucket"
}