variable "api_name" {
  description = "The name of the API Gateway"
  type        = string
}

variable "api_path" {
  description = "The resource path for the API Gateway"
  type        = string
}

variable "api_method" {
  description = "The HTTP method for the API Gateway resource"
  type        = string
}

variable "integration_uri" {
  description = "The URI of the backend integration"
  type        = string
}
