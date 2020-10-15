console.log("Loading function");
const AWS = require("aws-sdk");

const ORIGIN = 'http://warbler.s3-website.us-east-2.amazonaws.com';

exports.handler = async function(event, context) {
  console.log('Received event:', JSON.stringify(event, null, 4));

  conversation = event.requestContext.path;
  let payload = {
    Conversation: conversation,
    Timestamp: Date.now()
   };

  if (event.httpMethod == 'POST') {
    body = JSON.parse(event.body);
    user = (body.User || event.headers['X-Forwarded-For'] || 'Unknown').split(",")[0];
    payload.Message = body.Message || '<no message>';
    payload.User = user;
    await sendSns(payload);
    payload.Status = 'submitted';
  } else {
    payload.Messages = await listMessages(conversation);
  }

  const response = {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'Access-Control-Allow-Origin': ORIGIN
    },
    body: JSON.stringify(payload),
  }
  return response;
};

async function sendSns(payload) {
  const sns = new AWS.SNS();

  const params = {
      Message: JSON.stringify(payload),
      Subject: "chat message",
      TopicArn: "arn:aws:sns:us-east-2:893740494595:chat-message-topic"
  };
  return sns.publish(params).promise();
}

async function listMessages(conversation) {
  const dynamo = new AWS.DynamoDB();
  const params = {
    ExpressionAttributeValues: {
      ":a": {
        S: conversation
      }
    },
    FilterExpression: "Conversation = :a",
    TableName: "Messages"
  }

  let messages = await dynamo.scan(params).promise();

  return messages.Items.map(parseDynamoMessage);
}

function parseDynamoMessage(message) {
  return {
    Timestamp: parseInt(message['Timestamp']['N']),
    User: message['User']['S'],
    Message: message['Message']['S']
  }
}