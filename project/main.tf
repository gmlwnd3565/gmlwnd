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
