console.log("Loading function");
const AWS = require("aws-sdk");

exports.handler = async function(event, context) {
  console.log('Received event:', JSON.stringify(event, null, 4));

  user = (event.headers['X-Forwarded-For'] || 'Unknown').split(",")[0];
  conversation = event.requestContext.path;
  let payload = {
    user: user,
    conversation: conversation,
    timestamp: Date.now()
   };

  if (event.httpMethod == 'POST') {
    payload.message = event.body;
    await sendSns(payload);
    payload.status = 'submitted';
  } else {
    payload.messages = await listMessages(conversation);
  }

  const response = {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
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
  messages.Items = messages.Items.map(parseDynamoMessage);

  return messages;
}

function parseDynamoMessage(message) {
  return {
    timestamp: parseInt(message['Timestamp']['N']),
    user: message['User']['S'],
    message: message['Message']['S']
  }
}