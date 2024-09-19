resource "aws_cognito_user_pool" "user_pool" {
  name = var.user_pool_name

  lambda_config {
    pre_sign_up           = var.cognito_to_rds_function_arn        # 사용자가 가입 요청을 보낼 때 호출
    post_confirmation     = var.cognito_to_rds_function_arn        # 사용자가 가입 확인을 마친 후 호출
    pre_authentication  = var.cognito_to_rds_function_arn        # 사용자가 로그인 요청을 보낼 때 호출
    post_authentication = var.cognito_to_rds_function_arn        # 사용자가 성공적으로 로그인한 후 호출
    # custom_message      = var.cognito_to_rds_function_arn        # 메시지를 커스터마이즈할 때 호출
  }
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  user_pool_id = aws_cognito_user_pool.user_pool.id
  name         = "web-client"
}

