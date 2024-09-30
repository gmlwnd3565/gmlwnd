provider "aws" {
  region = "ap-northeast-2"
}

module "s3" {
  source      = "../../../modules/s3"
  bucket_name = "cloud-rigde-dev"
  dynamodb_table = "terraform-locks"
    # encrypt        = true
}

terraform {
  backend "s3" {
    bucket         = "cloud-rigde-dev"
    key            = "static/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}