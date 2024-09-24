output "rds_endpoint" {
  value = local.rds_exists ? data.aws_db_instance.existing_rds[0].endpoint : aws_db_instance.rds[0].endpoint
}

output "rds_username" {
  value = aws_db_instance.rds[0].username
  description = "RDS master username"
}

output "rds_db_name" {
  value = aws_db_instance.rds[0].db_name
  description = "RDS database name"
}

output "rds_password" {
  value = aws_db_instance.rds[0].password
  description = "RDS master password"
  sensitive = true
}