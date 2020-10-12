console.log("Loading function");
const AWS = require("aws-sdk");

exports.handler = async function(event, context) {
  console.log('Received event:', JSON.stringify(event, null, 4));

  user = (event.headers['X-Forwarded-For'] || 'Unknown').split(",")[0];
  let responseBody = `<p>User: ${user}</p>`;

  if (event.httpMethod == 'POST') {
    message = event.body;
    await sendSns(user, message);
    responseBody += `<p>Submitted ${message} for ${user}</p>`;
  } else {
    responseBody += `<p>Hello world</p>`;
  }

  const response = {
    statusCode: 200,
    headers: {
      'Content-Type': 'text/html; charset=utf-8',
    },
    body: responseBody,
  }
  return response;
};

async function sendSns(user, message) {
  const sns = new AWS.SNS();

  const params = {
      Message: JSON.stringify({
        user: user,
        message: message
      }),
      Subject: "chat message",
      TopicArn: "arn:aws:sns:us-east-2:893740494595:chat-message-topic"
  };
  return sns.publish(params).promise();
}