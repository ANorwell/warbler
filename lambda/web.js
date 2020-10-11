console.log("Loading function");
var AWS = require("aws-sdk");

exports.handler = async function(event, context) {
  console.log('Received event:', JSON.stringify(event, null, 4));

  await sendSns(event);

  let response = {
    statusCode: 200,
    headers: {
      'Content-Type': 'text/html; charset=utf-8',
    },
    body: '<p>Hello world 22!</p>',
  }
  return response;
};

async function sendSns(anEvent, context) {
  var sns = new AWS.SNS();
  var params = {
      Message: anEvent, 
      Subject: "Test SNS From Lambda",
      TopicArn: "arn:aws:sns:us-east-2:893740494595:chat-message-topic"
  };
  const promise = new Promise(function(resolve, reject) {
    sns.publish(params, resolve);
  })
  return promise;
};