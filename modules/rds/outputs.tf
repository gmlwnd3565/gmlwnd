output "endpoint" {
  value = aws_db_instance.rds.endpoint
}

output "username" {
  value = aws_db_instance.rds.username
}

output "db_name" {
  value = aws_db_instance.rds.db_name
}

output "password" {
  value = aws_db_instance.rds.password
  sensitive = true
}

output "port" {
  value = aws_db_instance.rds.port
}

output "instance_identifier" {
  value = aws_db_instance.rds.id
}

output "rds_subnet_group_name" {
  value = length(aws_db_subnet_group.rds_subnet_group) > 0 ? aws_db_subnet_group.rds_subnet_group[0].name : var.subnet_group_name
}