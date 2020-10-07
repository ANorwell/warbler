variable "lambda_function_filename" {
  type = string
}

variable "lambda_function_name" {
  type = string
}

variable "lambda_function_runtime" {
  type = string
}

variable "lambda_function_handler" {
  type = string
}


resource "aws_iam_role" "lambda_role" {
    name = "lambda-exec-role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "message_consumer_lambda" {
  filename      = var.lambda_function_filename
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_role.arn
  handler       = var.lambda_function_handler

  source_code_hash = filebase64sha256(var.lambda_function_filename)

  runtime = var.lambda_function_runtime

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs
  ]  
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.message_consumer_lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.chat-message.arn
}

# logging

resource "aws_cloudwatch_log_group" "message_consumer_logging" {
  name              = "/aws/lambda/${aws_lambda_function.message_consumer_lambda.function_name}"
  retention_in_days = 14
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}