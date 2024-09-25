terraform {
  backend "s3" {
    bucket         = "cloud-rigde-dev-tfstate"
    key            = "dynamic/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-locks"  # 선택 사항, 상태 잠금을 위해 DynamoDB 테이블을 생성한 경우
    encrypt        = true
  }
}