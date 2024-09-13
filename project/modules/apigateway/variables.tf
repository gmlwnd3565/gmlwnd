variable "api_name" {
  description = "The name of the API Gateway."
  type        = string
}

variable "api_stage_name" {
  description = "The stage name for the API Gateway (e.g., dev, prod)."
  type        = string
  default     = "dev"
}

variable "lambda_arn" {
  description = "The ARN of the Lambda function to integrate with API Gateway."
  type        = string
}

variable "integration_uri" {
  description = "The URI for the REST API integration."
  type        = string
}

variable "api_path" {
  description = "The path for the REST API resource."
  type        = string
}

variable "api_method" {
  description = "The HTTP method for the REST API resource."
  type        = string
}
