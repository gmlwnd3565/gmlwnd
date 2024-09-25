output "vpc_id" {
  value = module.vpc.vpc_id
}

output "bastion_instance_id" {
  value = module.bastion.bastion_instance_id
}

# output "lambda_function_name" {
#   value = module.lambda.lambda_function_name
# }

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "s3_bucket_name" {
  value = module.s3.bucket_name
}

output "rds_username" {
  value = module.rds.rds_username
  description = "RDS master username"
}

output "rds_db_name" {
  value = module.rds.rds_db_name
  description = "RDS database name"
}

output "rds_password" {
  value = module.rds.rds_password
  description = "RDS master password"
  sensitive = true
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "security_group_id" {
  value = module.security_group.security_group_id
}