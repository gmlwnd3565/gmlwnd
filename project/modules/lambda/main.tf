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
    }
  }
}

# data "aws_iam_role" "existing_lambda_role" {
#   name = "${var.lambda_function_name}-role"
# }

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
          "sqs:GetQueueAttributes"
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

# Attach the policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_sqs_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_sqs_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Call SQS module inside Lambda module
module "sqs" {
  source              = "./sqs"
  queue_name          = var.sqs_queue_name
  lambda_function_arn = aws_lambda_function.lambda_function.arn
}

# Call SNS module inside Lambda module
module "sns" {
  source              = "./sns"
  topic_name          = var.sns_topic_name
  lambda_function_arn = aws_lambda_function.lambda_function.arn
}

