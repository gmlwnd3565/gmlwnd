provider "aws" {
  region = "ap-northeast-2"
}

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

resource "aws_dynamodb_table" "tfstate_dynamodbtable" {
  name         = "tfstate-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}