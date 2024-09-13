resource "aws_cognito_user_pool" "user_pool" {
  name = var.user_pool_name
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  user_pool_id = aws_cognito_user_pool.user_pool.id
  name         = "web-client"
}
