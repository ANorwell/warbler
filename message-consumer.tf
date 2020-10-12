module "lambda_message_consumer" {
  source = "./modules/lambda-function"

  name = "consumer"
  filename = "lambda/consumer.zip"
  handler = "consumer.handler"
  runtime = "nodejs12.x"

  iam_role = aws_iam_role.lambda_role
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_message_consumer.lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.chat_message.arn
}
