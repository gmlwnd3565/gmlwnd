variable "aws_region" {
  description = "AWS Region for development environment"
  default     = "ap-northeast-2"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "VPC Name"
  default     = "my-vpc"
}

variable "allowed_ssh_cidr" {
  description = "Allowed CIDR block for SSH access"
  default     = "0.0.0.0/0"  # 일반적으로 본인의 IP로 제한하는 것이 안전합니다.
}

variable "lambda_function_name" {
  type        = string
  description = "The name of the Lambda function."
  default     = "lambda_function"  # 기본 Lambda 함수 이름
}

variable "lambda_nodejs_name" {
  type        = string
  description = "The name of the NodeJs function."
  default     = "cognito_to_rds_function"
}

variable "lambda_handler" {
  type        = string
  description = "The handler for the Lambda function."
  default     = "index.handler"  # 기본 Lambda 핸들러 (예: Node.js의 핸들러 형식)
}

variable "lambda_runtime" {
  type        = string
  description = "The runtime for the Lambda function."
  default     = "nodejs16.x"  # 기본 런타임 (Node.js 16)
}

variable "lambda_zip_file" {
  type        = string
  description = "Path to the zipped Lambda deployment package."
  default     = "lambda_function.zip"  # 기본 Lambda 배포 패키지 경로
}

variable "lambda_nodejs_file" {
  type        = string
  description = "Path to the zipped Cognito deployment package."
  default     = "cognito_function.zip"
}

variable "cognito_layer_file" {
  type        = string
  description = "The path to the Cognito zip file."
  default     = "cognito_layer.zip"
}

variable "slack_layer_file" {
  type        = string
  description = "The path to the Slack zip file."
  default     = "slack_layer.zip"
}

variable "lambda_environment_variables" {
  type        = map(string)
  description = "Environment variables for the Lambda function."
  default     = {
    ENV = "production"  # 기본 환경 변수 설정 (예: 프로덕션)
  }
}

variable "api_name" {
  type        = string
  description = "The name of the API Gateway."
  default     = "my_api_gateway"  # 기본 API Gateway 이름
}

variable "proxy_api_name" {
  description = "The name of the API Gateway."
  type        = string
  default     = "proxy_api_gateway"  # Proxy API Gateway 이름
}

variable "gateway_name" {
  type        = string
  description = "The name of the API Gateway."
  default     = "MyAPI"  # 기본 API Gateway 이름
}


variable "api_stage_name" {
  type        = string
  description = "The stage name for the API Gateway."
  default     = "dev"  # 기본 스테이지 이름 (예: 개발 환경)
}

variable "integration_uri" {
  description = "The URI for the REST API integration."
  type        = string
  default     = "http://www.wlgh921116.shop"
}

variable "api_path" {
  description = "The path for the REST API resource."
  type        = string
  default = "myresource"
}

variable "api_method" {
  description = "The HTTP method for the REST API resource."
  type        = string
  default     = "GET"
}