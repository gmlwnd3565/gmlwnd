resource "aws_sns_topic" "topic" {
  name = var.topic_name
}

resource "aws_sns_topic_subscription" "lambda_sns_subscription" {
  topic_arn = aws_sns_topic.topic.arn
  protocol  = "lambda"
  endpoint  = var.lambda_function_arn
}

resource "aws_lambda_permission" "allow_sns_invoke" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.topic.arn
}
