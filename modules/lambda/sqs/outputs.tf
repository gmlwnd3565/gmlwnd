output "sqs_queue_arn" {
  value = aws_sqs_queue.queue.arn
}

output "queue_url" {
  value = aws_sqs_queue.queue.id
}