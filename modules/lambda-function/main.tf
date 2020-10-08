variable "filename" {
  type = string
}

variable "name" {
  type = string
}

variable "runtime" {
  type = string
}

variable "handler" {
  type = string
}

variable "iam_role" {
  type = object({
    name = string
    arn = string
  })
}

variable "logging_policy_arn" {
  type = string
}

output "lambda" {
  value = aws_lambda_function.lambda
}

resource "aws_lambda_function" "lambda" {
  filename      = var.filename
  function_name = var.name
  role          = var.iam_role.arn
  handler       = var.handler

  source_code_hash = filebase64sha256(var.filename)

  runtime = var.runtime

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs
  ]  
}

resource "aws_cloudwatch_log_group" "message_consumer_logging" {
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = 14
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = var.iam_role.name
  policy_arn = var.logging_policy_arn
}