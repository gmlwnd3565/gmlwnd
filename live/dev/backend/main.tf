provider "aws" {
  region = "ap-northeast-2"
}

terraform {
  backend "s3" {
    # 이전에 생성한 버킷 이름
    bucket         = "cloud-rigde-dynamic-tfstate"
    key            = "dynamic/terraform.tfstate"
    region         = "ap-northeast-2"
    
    # 이전에 생성한 다이나모db 이름
    dynamodb_table = "terraform-locks"
    # encrypt        = true
  }
}

terraform {
  backend "s3" {
    # 이전에 생성한 버킷 이름
    bucket         = "cloud-rigde-dev-tfstate"
    key            = "static/terraform.tfstate"
    region         = "ap-northeast-2"
    
    # 이전에 생성한 다이나모db 이름
    dynamodb_table = "terraform-locks"
    # encrypt        = true
  }
}