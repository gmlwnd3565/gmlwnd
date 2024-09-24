provider "aws" {
  region = "ap-northeast-2"
}

# 이미 존재하는 S3 버킷 확인
data "aws_s3_bucket" "existing_s3bucket" {
  bucket = var.bucket_name
  count  = 0  # 에러를 방지하기 위해 기본적으로 count는 0으로 설정
}

# S3 버킷이 없을 경우에만 새로 생성
resource "aws_s3_bucket" "soon_s3bucket" {
  count  = length(data.aws_s3_bucket.existing_s3bucket) == 0 ? 1 : 0  # 버킷이 없을 경우에만 생성
  bucket = var.bucket_name

  # 리소스 삭제 시 테라폼 오류와 함께 종료됨
  # lifecycle {
  #   prevent_destroy = true
  # }
}

# S3 버킷 버전 관리 설정 (S3 버킷이 생성된 후 실행)
resource "aws_s3_bucket_versioning" "ssoon_s3bucket_versioning" {
  bucket = length(data.aws_s3_bucket.existing_s3bucket) > 0 ? data.aws_s3_bucket.existing_s3bucket[0].id : aws_s3_bucket.soon_s3bucket[0].id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 버킷 서버 측 암호화 설정 (S3 버킷이 생성된 후 실행)
resource "aws_s3_bucket_server_side_encryption_configuration" "soon_s3bucket_encryption" {
  bucket = length(data.aws_s3_bucket.existing_s3bucket) > 0 ? data.aws_s3_bucket.existing_s3bucket[0].id : aws_s3_bucket.soon_s3bucket[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 버킷 퍼블릭 액세스 차단 설정 (S3 버킷이 생성된 후 실행)
resource "aws_s3_bucket_public_access_block" "soon_s3bucket_public_access" {
  bucket = length(data.aws_s3_bucket.existing_s3bucket) > 0 ? data.aws_s3_bucket.existing_s3bucket[0].id : aws_s3_bucket.soon_s3bucket[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 이미 존재하는 DynamoDB 테이블 확인
data "aws_dynamodb_table" "existing_dynamodbtable" {
  name  = "terraform-locks"
  count = 0  # DynamoDB 테이블이 없을 때 에러가 발생하지 않도록 count를 0으로 설정
}

# DynamoDB 테이블이 없을 경우에만 새로 생성
resource "aws_dynamodb_table" "ssoon_dynamodbtable" {
  count        = length(data.aws_dynamodb_table.existing_dynamodbtable) == 0 ? 1 : 0  # DynamoDB 테이블이 없을 경우에만 생성
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
