output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "The public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "The private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "endpoint" {
  description = "RDS endpoint"
  value       = module.rds.endpoint
}

output "db_name" {
  description = "RDS database name"
  value       = module.rds.db_name
}

output "username" {
  description = "RDS master username"
  value       = module.rds.username
}

output "port" {
  description = "RDS port"
  value       = module.rds.port
}

output "bastion_public_ip" {
  description = "The public IP address of the bastion host"
  value       = module.bastion.public_ip
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}



output "ecr_repository_uri" {
  description = "The URL of the ECR repository"
  value       = module.ecr.ecr_repository_uri
}
