resource "aws_sqs_queue" "queue" {
  name = var.queue_name
}

resource "aws_lambda_event_source_mapping" "lambda_sqs_trigger" {
  event_source_arn = aws_sqs_queue.queue.arn
  function_name    = var.lambda_function_arn
  enabled          = true
}

resource "aws_lambda_permission" "allow_sqs_invoke" {
  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_arn
  principal     = "sqs.amazonaws.com"
  source_arn    = aws_sqs_queue.queue.arn
}
