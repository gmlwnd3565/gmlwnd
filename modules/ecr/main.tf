# 1. 이미 존재하는 ECR 리포지토리 확인
data "aws_ecr_repository" "existing_repo" {
  name  = var.repository_name
  count = 0  # 존재하지 않을 경우 에러를 방지하기 위해 count 0으로 설정
}

# 2. ECR 리포지토리가 존재하는지 여부를 locals에 저장
locals {
  ecr_exists = length(data.aws_ecr_repository.existing_repo) > 0
}

# 3. ECR 리포지토리가 없을 경우에만 새로 생성
resource "aws_ecr_repository" "repo" {
  count = local.ecr_exists ? 0 : 1  # ECR 리포지토리가 없을 경우에만 생성
  name  = var.repository_name
  image_tag_mutability = "MUTABLE"

  tags = {
    Name = var.repository_name
  }
}