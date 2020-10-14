resource "aws_dynamodb_table" "message_dynamodb_table" {
  name           = "Messages"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "Conversation"
  range_key      = "Timestamp"

  attribute {
    name = "Timestamp"
    type = "N"
  }

  attribute {
    name = "Conversation"
    type = "S"
  }

  tags = {
    Name        = "messages-table-1"
    Environment = "production"
  }
}