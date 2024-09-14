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

# output "api_gateway_url" {
#   value = module.api_gateway.api_gateway_url
# }
