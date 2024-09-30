output "vpc_id" {
  value = module.vpc.vpc_id
}

output "bastion_instance_id" {
  value = module.bastion.bastion_instance_id
}

# output "lambda_function_name" {
#   value = module.lambda.lambda_function_name
# }

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "endpoint" {
  value = module.rds.endpoint
}

output "username" {
  value = module.rds.username
}

output "db_name" {
  value = module.rds.db_name
}

output "password" {
  value = module.rds.password
  sensitive = true
}

output "port" {
  value = module.rds.port
}

output "instance_identifier" {
  value = module.rds.instance_identifier
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


output "rds_subnet_group_name" {
  value = "mydb-subnet-group"
}
