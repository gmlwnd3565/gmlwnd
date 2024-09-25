provider "aws" {
  region = "ap-northeast-2"
}

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
  source              = "../../../modules/lambda"
  lambda_function_name = var.lambda_function_name
  lambda_zip_file      = var.lambda_zip_file
  lambda_env           = "production"
  sqs_queue_name       = "my_sqs_queue"
  sns_topic_name       = "my_sns_topic"
  cognito_layer_file   = var.cognito_layer_file
  slack_layer_file     = var.slack_layer_file
  lambda_nodejs_name   = var.lambda_nodejs_name
  lambda_nodejs_file   = var.lambda_nodejs_file
}

module "api" {
  source          = "../../../modules/apigateway"
  api_name        = var.api_name
  api_stage_name  = var.api_stage_name
  lambda_arn      = module.lambda.lambda_function_arn
  api_path        = var.api_path
  api_method      = var.api_method
  integration_uri = var.integration_uri
}

module "cognito" {
  source          = "../../../modules/cognito"
  user_pool_name  = "dev-user-pool"
  cognito_to_rds_function_arn = module.lambda.cognito_to_rds_function_arn
}

resource "aws_lambda_permission" "allow_cognito_invoke_lambda" {
  statement_id  = "AllowCognitoInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_nodejs_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = module.cognito.cognito_user_pool_arn
}

module "transit_gateway" {
  source = "../../../modules/transit_gateway"
}

# # Dev VPC와 Transit Gateway 연결
# resource "aws_ec2_transit_gateway_vpc_attachment" "dev_vpc_attachment" {
#   vpc_id             = "vpc-xxxxxxxx"  # Dev VPC ID를 입력하세요
#   subnet_ids         = ["subnet-xxxxxxxx"]  # Dev 서브넷 ID를 입력하세요
#   transit_gateway_id = module.transit_gateway.this.id

#   tags = {
#     Name = "dev-vpc-attachment"
#   }
# }

# # Prod VPC와 Transit Gateway 연결
# resource "aws_ec2_transit_gateway_vpc_attachment" "prod_vpc_attachment" {
#   vpc_id             = "vpc-yyyyyyyy"  # Prod VPC ID를 입력하세요
#   subnet_ids         = ["subnet-yyyyyyyy"]  # Prod 서브넷 ID를 입력하세요
#   transit_gateway_id = module.transit_gateway.this.id

#   tags = {
#     Name = "prod-vpc-attachment"
#   }
# }

# # Dev VPC 라우팅 테이블에서 Prod VPC로의 트래픽을 Transit Gateway로 보냄
# resource "aws_route" "dev_vpc_to_prod" {
#   route_table_id         = var.dev_route_table_id  # Dev VPC의 라우팅 테이블 ID를 입력하세요
#   destination_cidr_block = "10.1.0.0/16"  # Prod VPC의 CIDR 블록을 입력하세요
#   transit_gateway_id     = module.transit_gateway.this.id
# }

# # Prod VPC 라우팅 테이블에서 Dev VPC로의 트래픽을 Transit Gateway로 보냄
# resource "aws_route" "prod_vpc_to_dev" {
#   route_table_id         = var.prod_route_table_id  # Prod VPC의 라우팅 테이블 ID를 입력하세요
#   destination_cidr_block = "10.0.0.0/16"  # Dev VPC의 CIDR 블록을 입력하세요
#   transit_gateway_id     = module.transit_gateway.this.id
# }