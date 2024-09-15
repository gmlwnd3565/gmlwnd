resource "aws_lambda_function" "lambda_function" {
  function_name = var.lambda_function_name
  runtime       = "nodejs16.x"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  filename      = var.lambda_zip_file
  source_code_hash = filebase64sha256(var.lambda_zip_file)

  environment {
    variables = {
      ENV = var.lambda_env
      SQS_ENV = module.sqs.queue_url
      SNS_ENV = module.sns.sns_topic_arn
    }
  }
}

resource "aws_lambda_function" "nodejs_function" {
  function_name = var.lambda_nodejs_name
  runtime       = "nodejs16.x"
  role          = aws_iam_role.nodejs_role.arn
  handler       = "cognito_to_rds.handler"
  filename      = var.lambda_nodejs_file
  source_code_hash = filebase64sha256(var.lambda_nodejs_file)

  environment {
    variables = {
      RDS_ENDPOINT   = data.terraform_remote_state.rds.outputs.rds_endpoint
      RDS_DB_NAME    = data.terraform_remote_state.rds.outputs.rds_db_name
      RDS_USERNAME   = data.terraform_remote_state.rds.outputs.rds_username
      RDS_PASSWORD   = data.terraform_remote_state.rds.outputs.rds_password
    }
  }

  vpc_config {
    security_group_ids = [data.terraform_remote_state.security_groups.outputs.security_group_id]
    subnet_ids         = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  }

  layers = [
    aws_lambda_layer_version.mysql_layer.arn
  ]
}

resource "aws_lambda_layer_version" "mysql_layer" {
  filename   = var.nodejs_zip_file
  layer_name = "nodejs-layer"
  compatible_runtimes = ["nodejs14.x", "nodejs16.x", "nodejs18.x"]
}

resource "aws_iam_role" "lambda_role" {
  # count = length(data.aws_iam_role.existing_lambda_role.arn) == 0 ? 1 : 0
  name = "${var.lambda_function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_role" "nodejs_role" {
  # count = length(data.aws_iam_role.existing_lambda_role.arn) == 0 ? 1 : 0
  name = "${var.lambda_nodejs_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# data "aws_iam_policy" "existing_lambda_sqs_policy" {
#   name = var.lambda_sqs_policy
# }
# IAM Policy for Lambda to interact with SQS
resource "aws_iam_policy" "lambda_sqs_policy" {
  name        = "lambda_sqs_policy"
  description = "IAM policy for Lambda to interact with SQS"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:SendMessage"
        ],
        Effect   = "Allow",
        Resource = module.sqs.sqs_queue_arn
      },
      {
        Action: "sns:Publish",
        Effect: "Allow",
        Resource: "*"  # 모든 SNS 주제에 대한 접근 허용 (특정 주제로 제한 가능)
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_exec_policy" {
  name = "lambda_exec_policy"
  description = "IAM policy for Lambda to interact with EC2"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets"
        ]
        Resource = "*"
        Effect = "Allow"
      }
    ]
  })
}

# Attach the policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_sqs_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_sqs_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_ec2_policy_attachment" {
  role       = aws_iam_role.nodejs_role.name
  policy_arn = aws_iam_policy.lambda_exec_policy.arn
}

# Call SQS module inside Lambda module
module "sqs" {
  source              = "./sqs"
  queue_name          = var.sqs_queue_name
  lambda_function_arn = aws_lambda_function.lambda_function.arn
}

# SNS module 호출
module "sns" {
  source              = "./sns"
  topic_name          = var.sns_topic_name
  lambda_function_arn = aws_lambda_function.lambda_function.arn
}

# CloudWatch module 호출
module "cloudwatch" {
  source           = "../cloudwatch"
  log_group_name   = "aws-waf-logs-${var.lambda_function_name}"
  retention_in_days = var.cloudwatch_retention_in_days
}

# Cognito Lambda 설정
resource "aws_cognito_user_pool" "user_pool" {
  name = "user_pool"

  lambda_config {
    pre_sign_up           = aws_lambda_function.nodejs_function.arn        # 사용자가 가입 요청을 보낼 때 호출
    post_confirmation     = aws_lambda_function.nodejs_function.arn        # 사용자가 가입 확인을 마친 후 호출
    # pre_authentication  = aws_lambda_function.nodejs_function.arn        # 사용자가 로그인 요청을 보낼 때 호출
    # post_authentication = aws_lambda_function.nodejs_function.arn       # 사용자가 성공적으로 로그인한 후 호출
    # custom_message      = aws_lambda_function.nodejs_function.arn        # 메시지를 커스터마이즈할 때 호출
  }
}

resource "aws_lambda_permission" "allow_cognito_invoke_lambda" {
  statement_id  = "AllowCognitoInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.nodejs_function.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.user_pool.arn
}

data "terraform_remote_state" "vpc" {
  backend = "local"
  config = {
    path = "../../live/dev/static/terraform.tfstate"
  }
}

data "terraform_remote_state" "rds" {
  backend = "local"
  config = {
    path = "../../live/dev/static/terraform.tfstate"
  }
}

data "terraform_remote_state" "subnets" {
  backend = "local"
  config = {
    path = "../../live/dev/static/terraform.tfstate"
  }
}

data "terraform_remote_state" "security_groups" {
  backend = "local"
  config = {
    path = "../../live/dev/static/terraform.tfstate"
  }
}