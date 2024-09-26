provider "aws" {
  region = "ap-northeast-2"
}

module "lambda" {
  source              = "../../../modules/lambda"
  lambda_function_name = var.lambda_function_name
  lambda_zip_file      = var.lambda_zip_file
  lambda_env           = "production"
  sqs_queue_name       = "my_sqs_queue"
  sns_topic_name       = "my_sns_topic"
  cognito_layer_file   = var.cognito_layer_file
  slack_layer_file     = var.slack_layer_file
  lambda_nodejs_name   = var.lambda_nodejs_name
  lambda_nodejs_file   = var.lambda_nodejs_file
}

module "api" {
  source          = "../../../modules/apigateway"
  api_name        = var.api_name
  proxy_api_name  = var.proxy_api_name
  api_stage_name  = var.api_stage_name
  lambda_arn      = module.lambda.lambda_function_arn
  api_path        = var.api_path
  api_method      = var.api_method
  integration_uri = var.integration_uri
}

module "cognito" {
  source          = "../../../modules/cognito"
  user_pool_name  = "dev-user-pool"
  cognito_to_rds_function_arn = module.lambda.cognito_to_rds_function_arn
}

resource "aws_lambda_permission" "allow_cognito_invoke_lambda" {
  statement_id  = "AllowCognitoInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_nodejs_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = module.cognito.cognito_user_pool_arn
}

module "transit_gateway" {
  source = "../../../modules/transit_gateway"
}