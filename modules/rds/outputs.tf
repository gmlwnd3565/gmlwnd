output "rds_endpoint" {
  value = aws_db_instance.rds.endpoint
}

output "rds_username" {
  value = aws_db_instance.rds.username
  description = "RDS master username"
}

output "rds_db_name" {
  value = aws_db_instance.rds.db_name
  description = "RDS database name"
}

output "rds_password" {
  value = aws_db_instance.rds.password
  description = "RDS master password"
  sensitive = true
}