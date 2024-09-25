provider "aws" {
  region = "ap-northeast-2"
}

data "terraform_remote_state" "vpc" {
  backend = "s3"  # VPC 모듈의 상태 저장 위치
  config = {
    bucket = "cloud-rigde-dev"
    key    = "static/terraform.tfstate"
    region = "ap-northeast-2"
  }
}

module "eks" {
  source              = "../../../modules/eks"
  cluster_name        = "dev-eks"
  cluster_version     = "1.30"
  subnet_ids          = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  iam_role_name       = "eks-role"
  desired_capacity    = 2
  max_capacity        = 4
  min_capacity        = 2
  instance_type       = "t3.large"
}
