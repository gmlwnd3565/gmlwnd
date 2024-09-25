provider "aws" {
  region = "ap-northeast-2"
}

module "s3" {
  source      = "../../../modules/s3"
  bucket_name = "cloud-rigde-dev"
  dynamodb_table = "terraform-locks"
    # encrypt        = true
}

module "s3_tfstate" {
  source      = "../../../modules/s3"
  bucket_name = "cloud-rigde-dev-tfstate"
  dynamodb_table = "terraform-locks"
    # encrypt        = true
}