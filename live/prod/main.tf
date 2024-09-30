provider "aws" {
  region = "ap-northeast-2"
}

# dev 환경에서 배포된 리소스를 불러오기 (Terraform Remote State 사용)
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "cloud-rigde-dev"  # dev 환경의 S3 상태 저장 버킷
    key    = "static/terraform.tfstate"
    region = "ap-northeast-2"
  }
}

# prod VPC 구성
module "vpc" {
  source = "../../modules/vpc"
  
  cidr_block           = "10.1.0.0/16"  # prod VPC의 CIDR 블록
  public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnet_cidrs = ["10.1.3.0/24", "10.1.4.0/24"]
  azs                  = ["ap-northeast-2a", "ap-northeast-2c"]
  name                 = "prod-vpc"
}

# prod 환경의 RDS 설정 (dev 환경의 RDS 정보 참조)
module "rds" {
  source              = "../../modules/rds"
  db_name             = data.terraform_remote_state.vpc.outputs.db_name
  username            = data.terraform_remote_state.vpc.outputs.username
  password            = data.terraform_remote_state.vpc.outputs.password
  instance_class      = "db.t3.micro" 
  instance_identifier = "prod-rds"
  subnet_group        = [data.terraform_remote_state.vpc.outputs.rds_subnet_group_name]
  security_group_id   = data.terraform_remote_state.vpc.outputs.security_group_id  # dev 환경의 보안 그룹 참조
  subnet_ids          = data.terraform_remote_state.vpc.outputs.private_subnet_ids  # dev 서브넷 참조
  
  # prod 환경에서 새로 생성하지 않고 dev의 서브넷 그룹과 RDS 참조
  create_subnet_group = false  
  subnet_group_name   = data.terraform_remote_state.vpc.outputs.rds_subnet_group_name
}

# prod 환경에 bastion 호스트 설정
module "bastion" {
  source              = "../../modules/bastion_host"
  bastion_ami         = "ami-07d737d4d8119ad79"
  bastion_instance_type = "t2.micro"
  public_subnet_id    = module.vpc.public_subnet_ids[0]
  key_name            = "teamProject"
}

# prod 환경에 ALB 설정
module "alb" {
  source              = "../../modules/alb"
  alb_name            = "prod-alb"
  public_subnets      = module.vpc.public_subnet_ids
  security_groups     = [module.security_group.security_group_id]
}

# prod 환경의 ECR 설정
module "ecr" {
  source = "../../modules/ecr"
  repository_name = "prod-repo"
}

# prod 환경의 보안 그룹 설정
module "security_group" {
  source = "../../modules/security_groups"
  name   = "prod-rds-security-group"
  vpc_id = module.vpc.vpc_id

  ingress_port = [3306, 22, 80, 443, 65535] 
  protocol     = "tcp"
  cidr_blocks  = ["0.0.0.0/0"]  # 필요에 맞게 IP 제한
}

