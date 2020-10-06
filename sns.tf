terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-2"
}

resource "aws_sns_topic" "chat-message" {
  name = "chat-message-topic"
  lambda_failure_feedback_role_arn = "arn:aws:iam::893740494595:role/SNSFailureFeedback" # TODO
}

resource "aws_sns_topic_subscription" "message_consumer_lambda_target" {
  topic_arn = aws_sns_topic.chat-message.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.message_consumer_lambda.arn
}
