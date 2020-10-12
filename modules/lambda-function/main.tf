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
    arn = string
  })
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
}

resource "aws_cloudwatch_log_group" "logging" {
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = 14
}

