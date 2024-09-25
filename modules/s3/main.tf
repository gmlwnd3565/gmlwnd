provider "aws" {
  region = "ap-northeast-2"
}

# S3 버킷이 없을 경우에만 새로 생성
resource "aws_s3_bucket" "soon_s3bucket" {
  bucket = var.bucket_name

  # 리소스 삭제 시 테라폼 오류와 함께 종료됨
  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "aws_s3_bucket_versioning" "ssoon_s3bucket_versioning" {
  bucket = aws_s3_bucket.soon_s3bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 버킷 서버 측 암호화 설정 (S3 버킷이 생성된 후 실행)
resource "aws_s3_bucket_server_side_encryption_configuration" "soon_s3bucket_encryption" {
  bucket = aws_s3_bucket.soon_s3bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "soon_s3bucket_public_access" {
  bucket = aws_s3_bucket.soon_s3bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_dynamodb_table" "ssoon_dynamodbtable" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}