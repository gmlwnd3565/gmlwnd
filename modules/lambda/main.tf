resource "aws_lambda_function" "lambda_function" {
  function_name = var.lambda_function_name
  runtime       = "nodejs16.x"
  role          = aws_iam_role.lambda_role.arn
  handler       = "cloudwatch.handler"
  filename      = var.lambda_zip_file
  source_code_hash = filebase64sha256(var.lambda_zip_file)

  environment {
    variables = {
      ENV = var.lambda_env
      SQS_ENV = module.sqs.queue_url
      SNS_ENV = module.sns.sns_topic_arn
      SLACK_WEBHOOK_URL = "https://hooks.slack.com/services/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"
    }
  }
}

resource "aws_lambda_function" "cognito_to_rds_function" {
  function_name = var.lambda_nodejs_name
  runtime       = "nodejs16.x"
  role          = aws_iam_role.nodejs_role.arn
  handler       = "cognito_to_rds.handler"
  filename      = var.lambda_nodejs_file
  source_code_hash = filebase64sha256(var.lambda_nodejs_file)

  environment {
    variables = {
      RDS_ENDPOINT   = data.terraform_remote_state.all.outputs.rds_endpoint
      RDS_DB_NAME    = data.terraform_remote_state.all.outputs.rds_db_name
      RDS_USERNAME   = data.terraform_remote_state.all.outputs.rds_username
      RDS_PASSWORD   = data.terraform_remote_state.all.outputs.rds_password
    }
  }

  vpc_config {
    security_group_ids = [data.terraform_remote_state.all.outputs.security_group_id]
    subnet_ids         = data.terraform_remote_state.all.outputs.public_subnet_ids
  }

  layers = [
    aws_lambda_layer_version.cognito_layer.arn
  ]
}

resource "aws_lambda_layer_version" "cognito_layer" {
  filename   = var.cognito_layer_file
  layer_name = "cognito-layer"
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

data "terraform_remote_state" "all" {
  backend = "s3"
  config = {
    bucket         = "cloud-rigde-dev-tfstate"  # static의 상태 파일이 저장된 S3 버킷
    key            = "static/terraform.tfstate"   # static의 상태 파일 경로
    region         = "ap-northeast-2"                  # S3 버킷의 리전
  }
}

# data "terraform_remote_state" "rds" {
#   backend = "s3"
#   config = {
#     bucket         = "cloud-rigde-dev-tfstate"  # static의 상태 파일이 저장된 S3 버킷
#     key            = "static/terraform.tfstate"   # static의 상태 파일 경로
#     region         = "ap-northeast-2"                  # S3 버킷의 리전
#   }
# }

# data "terraform_remote_state" "subnets" {
#   backend = "s3"
#   config = {
#     bucket         = "cloud-rigde-dev-tfstate"  # static의 상태 파일이 저장된 S3 버킷
#     key            = "static/terraform.tfstate"   # static의 상태 파일 경로
#     region         = "ap-northeast-2"                  # S3 버킷의 리전
#   }
# }

# data "terraform_remote_state" "security_groups" {
#   backend = "s3"
#   config = {
#     bucket         = "cloud-rigde-dev-tfstate"  # static의 상태 파일이 저장된 S3 버킷
#     key            = "static/terraform.tfstate"   # static의 상태 파일 경로
#     region         = "ap-northeast-2"                  # S3 버킷의 리전
#   }
# }

# data "terraform_remote_state" "cognito" {
#   backend = "s3"
#   config = {
#     bucket         = "cloud-rigde-dev-tfstate"  # static의 상태 파일이 저장된 S3 버킷
#     key            = "static/terraform.tfstate"   # static의 상태 파일 경로
#     region         = "ap-northeast-2"                  # S3 버킷의 리전
#   }
# }