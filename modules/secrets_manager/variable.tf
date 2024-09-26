variable "secret_name" {
  type        = string
  description = "Name of the secret"
}

variable "description" {
  type        = string
  description = "Description of the secret"
  default     = ""
}

variable "username" {
  type        = string
  description = "Database username"
}

variable "password" {
  type        = string
  description = "Database password"
}

variable "engine" {
  type        = string
  description = "Database engine (e.g., mysql)"
}

variable "host" {
  type        = string
  description = "Database host (endpoint)"
}

variable "port" {
  type        = number
  description = "Database port"
}

variable "dbname" {
  type        = string
  description = "Database name"
}

variable "db_instance_identifier" {
  type        = string
  description = "DB instance identifier"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the secret"
  default     = {}
}
