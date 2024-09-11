output "api_gateway_id" {
  description = "ID of the API Gateway."
  value       = aws_apigatewayv2_api.api_gateway.id
}

output "api_gateway_url" {
  description = "URL of the API Gateway."
  value       = aws_apigatewayv2_stage.api_stage.invoke_url
}
