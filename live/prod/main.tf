# provider "aws" {
#   region = "ap-northeast-2"
# }

# module "vpc" {
#   source = "../../modules/vpc"
  
#   cidr_block           = "10.0.0.0/16"
#   public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
#   private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
#   azs                  = ["ap-northeast-2a", "ap-northeast-2c"]
#   name                 = "prod-vpc"
# }

# module "bastion" {
#   source            = "../../modules/bastion_host"
#   bastion_ami       = "ami-07d737d4d8119ad79"
#   bastion_instance_type = "t2.micro"
#   public_subnet_id  = module.vpc.public_subnet_ids[0]
#   key_name          = "teamProject"
# }

# module "rds" {
#   source         = "../../modules/rds"
#   db_name        = "mydb"
#   username       = "admin"
#   password       = "password"
#   instance_class = "db.t3.micro"  # t3.micro로 변경
#   subnet_group   = module.vpc.private_subnet_ids
#   security_group_id = module.security_group.security_group_id
# }

# module "security_group" {
#   source = "../../modules/security_groups"
#   name   = "rds-security-group"
#   vpc_id = module.vpc.vpc_id

#   ingress_port = [3306, 22, 80]  # MySQL RDS에 필요한 포트
#   protocol     = "tcp"
#   cidr_blocks  = ["0.0.0.0/0"]  # 필요에 맞게 수정 (예: 제한된 IP로 설정)
# }

# module "s3" {
#   source      = "../../modules/s3"
#   bucket_name = "cloud-rigde"
# }


# module "cognito" {
#   source          = "../../modules/cognito"
#   user_pool_name  = "prod-user-pool"
# }

# module "ecr" {
#   source = "../../modules/ecr"
#   repository_name = "prod-repo"
# }

# module "alb" {
#   source         = "../../modules/alb"
#   alb_name       = "prod-alb"
#   public_subnets = module.vpc.public_subnet_ids

#   security_groups = [module.security_group.security_group_id]  # 리스트로 변환하여 전달
# }


module "lambda" {
  source              = "../../modules/lambda"
  lambda_function_name = var.lambda_function_name
  lambda_zip_file      = var.lambda_zip_file
  lambda_env           = "production"
  sqs_queue_name       = "my_sqs_queue"
  sns_topic_name       = "my_sns_topic"
  nodejs_zip_file      = var.nodejs_zip_file
  lambda_nodejs_name   = var.lambda_nodejs_name
  lambda_nodejs_file   = var.lambda_nodejs_file
}

module "api" {
  source          = "../../modules/apigateway"
  api_name        = var.api_name
  api_stage_name  = var.api_stage_name
  lambda_arn      = module.lambda.lambda_function_arn
  api_path        = var.api_path
  api_method      = var.api_method
  integration_uri = var.integration_uri
}
