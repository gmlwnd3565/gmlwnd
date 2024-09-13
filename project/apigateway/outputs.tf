output "api_gateway_id" {
  description = "ID of the HTTP API Gateway"
  value       = aws_apigatewayv2_api.api_gateway.id
}

output "api_gateway_url" {
  description = "The URL for the deployed HTTP API Gateway"
  value       = aws_apigatewayv2_api.api_gateway.api_endpoint
}

output "rest_api_id" {
  description = "ID of the REST API Gateway"
  value       = aws_api_gateway_rest_api.rest_api.id
}

output "rest_api_url" {
  description = "The URL for the deployed REST API"
  value       = aws_api_gateway_rest_api.rest_api.execution_arn
}

output "api_stage_name" {
  description = "The stage name for the API Gateway"
  value       = aws_apigatewayv2_stage.api_stage.name
}

output "api_stage_url" {
  description = "The full URL of the API Gateway stage"
  value       = "${aws_apigatewayv2_api.api_gateway.api_endpoint}/${aws_apigatewayv2_stage.api_stage.name}"
}
