provider "aws" {
  region = "ap-northeast-2"
}

module "vpc" {
  source = "../../../modules/vpc"
  
  cidr_block           = "10.1.0.0/16"
  public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnet_cidrs = ["10.1.3.0/24", "10.1.4.0/24"]
  azs                  = ["ap-northeast-2a", "ap-northeast-2c"]
  name                 = "prod-vpc"
}

module "bastion" {
  source            = "../../../modules/bastion_host"
  bastion_ami       = "ami-07d737d4d8119ad79"
  bastion_instance_type = "t2.micro"
  public_subnet_id  = module.vpc.public_subnet_ids[0]
  key_name          = "teamProject"
}

module "rds" {
  source         = "../../../modules/rds"
  db_name        = "mydb"
  username       = "admin"
  password       = "password"
  instance_class = "db.t3.micro"  # t3.micro로 변경
  subnet_group   = module.vpc.private_subnet_ids
  security_group_id = module.security_group.security_group_id
}

module "security_group" {
  source = "../../../modules/security_groups"
  name   = "rds-security-group"
  vpc_id = module.vpc.vpc_id

  ingress_port = [3306, 22, 80]  # MySQL RDS에 필요한 포트
  protocol     = "tcp"
  cidr_blocks  = ["0.0.0.0/0"]  # 필요에 맞게 수정 (예: 제한된 IP로 설정)
}

module "s3" {
  source      = "../../../modules/s3"
  bucket_name = "cloud-rigde-prod"
}


module "cognito" {
  source          = "../../../modules/cognito"
  user_pool_name  = "prod-user-pool"
}

module "ecr" {
  source = "../../../modules/ecr"
  repository_name = "prod-repo"
}

module "alb" {
  source         = "../../../modules/alb"
  alb_name       = "prod-alb"
  public_subnets = module.vpc.public_subnet_ids

  security_groups = [module.security_group.security_group_id]  # 리스트로 변환하여 전달
}

module "transit_gateway" {
  source = "../../../modules/transit_gateway"

  dev_vpc_id      = module.dev_vpc.vpc_id
  prod_vpc_id     = module.prod_vpc.vpc_id
  dev_subnet_ids  = module.dev_vpc.private_subnet_ids
  prod_subnet_ids = module.prod_vpc.private_subnet_ids
}

module "prod_routing" {
  source = "../../../modules/vpc"

  transit_gateway_id = module.transit_gateway.transit_gateway_id
  dev_vpc_cidr       = "10.0.0.0/16"  # 개발 VPC의 CIDR 블록
  prod_vpc_cidr      = "10.1.0.0/16"  # 프로덕션 VPC의 CIDR 블록
}