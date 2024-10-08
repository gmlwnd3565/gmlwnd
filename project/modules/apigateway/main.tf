# API Gateway v2 (HTTP API) 생성
resource "aws_apigatewayv2_api" "api_gateway" {
  name          = var.api_name
  protocol_type = "HTTP"
}

# API Gateway 스테이지 설정
resource "aws_apigatewayv2_stage" "api_stage" {
  api_id = aws_apigatewayv2_api.api_gateway.id
  name   = var.api_stage_name
}

# Lambda 통합 설정 (AWS_PROXY 통합)
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.api_gateway.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.lambda_arn
}

# API Route 설정 (모든 HTTP 메서드 및 경로 지원)
resource "aws_apigatewayv2_route" "api_route" {
  api_id    = aws_apigatewayv2_api.api_gateway.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# REST API 방식으로 추가한 다른 API와 통합
resource "aws_api_gateway_rest_api" "rest_api" {
  name        = var.api_name
  description = "REST API for ${var.api_name}"

  tags = {
    Name = var.api_name
  }
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = var.api_path
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = var.api_method
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "rest_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  type                    = "HTTP"
  integration_http_method = "POST"
  uri                     = var.integration_uri
}
