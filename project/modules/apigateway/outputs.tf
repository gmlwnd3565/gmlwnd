output "api_id" {
  value = aws_api_gateway_rest_api.api.id
}

output "api_url" {
  value = aws_api_gateway_rest_api.api.execution_arn
}