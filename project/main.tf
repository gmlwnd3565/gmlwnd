provider "aws" {
  region = "ap-northeast-2" # 사용할 AWS 리전
}

# VPC 생성
module "vpc" {
  source  = "./modules/vpc"
  vpc_cidr = "10.0.0.0/16"
  vpc_name = "my-vpc"
}

# 서브넷 생성
module "subnets" {
  source          = "./modules/subnets"
  vpc_id          = module.vpc.vpc_id
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
  azs             = ["ap-northeast-2a", "ap-northeast-2c"]
  vpc_name        = "my-vpc"
}

# NAT Gateway 생성
module "nat" {
  source            = "./modules/nat"
  vpc_id            = module.vpc.vpc_id
  public_subnet_id  = module.subnets.public_subnet_ids[0] 
  private_subnet_ids = module.subnets.private_subnet_ids
  internet_gateway_id = module.vpc.internet_gateway_id
  vpc_name        = "my-vpc"
  nat_name          = "my-nat-gateway" 
}

# 보안 그룹 생성
module "security_group" {
  source          = "./modules/security_groups"
  vpc_id          = module.vpc.vpc_id
  vpc_cidr        = "10.0.0.0/16"
  vpc_name        = "my-vpc"
  allowed_ssh_cidr = "0.0.0.0/0"
}

# Bastion Host 생성
module "bastion" {
  source          = "./modules/bastion_host"
  ami_id          = "ami-07d737d4d8119ad79"  # 원하는 AMI ID로 변경
  subnet_id       = element(module.subnets.public_subnet_ids, 0)
  key_name        = "teamProject"            # 자신의 키페어 이름으로 변경
  security_group_id = module.security_group.bastion_sg_id        # 적절한 보안 그룹 ID로 변경
}

# ECR 생성
module "ecr" {
  source          = "./modules/ecr"
  repository_name = "my-ecr-repository"
}

# RDS 생성
module "rds" {
  source               = "./modules/rds"
  db_identifier        = "my-rds-instance"
  db_name              = "mydatabase"
  db_username          = "admin"
  db_password          = "soldesk123"      # 실제로는 변수를 사용하는 것이 좋습니다.
  db_engine            = "mysql"
  db_instance_class    = "db.t3.micro"
  subnet_ids           = module.subnets.public_subnet_ids  # 퍼블릭 서브넷 사용
  security_group_id    = module.security_group.nat_sg_id
}

terraform {
  backend "s3" {
    # 이전에 생성한 버킷 이름
    bucket         = "test-soldesk"
    key            = "project"
    region         = "ap-northeast-2"
    
    # 이전에 생성한 다이나모db 이름
    dynamodb_table = "test"
    # encrypt        = true
  }
}

# module "apigateway" {
#   source          = "./modules/apigateway"
#   api_name        = "my-api"
#   api_path        = "myresource"
#   api_method      = "GET"
#   integration_uri = "https://your-backend-url"  # API의 백엔드 URI
# }

# # Cognito 생성
# module "cognito" {
#   source              = "./modules/cognito"
#   user_pool_name      = "my-user-pool"
#   user_pool_client_name = "my-user-pool-client"
# }dawd