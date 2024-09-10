resource "aws_dynamodb_table" "ssoon_dynamodbtable" {
  name         = "test"
  billing_mode = "PAY_PER_REQUEST" 
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}