resource "aws_sns_topic" "chat_message" {
  name = "chat-message-topic"
  lambda_failure_feedback_role_arn = aws_iam_role.sns_failure_logging.arn
}

resource "aws_sns_topic_subscription" "message_consumer_lambda_target" {
  topic_arn = aws_sns_topic.chat_message.arn
  protocol  = "lambda"
  endpoint  = module.lambda_message_consumer.lambda.arn
}

# Create a role for failure logging, with associated policy that allows logging

resource "aws_iam_role" "sns_failure_logging" {
  name = "sns-failure-logging"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "sns.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "sns_failure_logging" {
  name = "sns-failure-logging"
  path        = "/"
  description = "IAM policy for failure logging an sns topic"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:PutMetricFilter",
                "logs:PutRetentionPolicy"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF  
}

resource "aws_iam_role_policy_attachment" "sns-failure-logging" {
  role       = aws_iam_role.sns_failure_logging.name
  policy_arn = aws_iam_policy.sns_failure_logging.arn
}

output "sns_topic_arn" {
  value = aws_sns_topic.chat_message.arn
}