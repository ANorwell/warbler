console.log('Loading function');

const AWS = require("aws-sdk");

exports.handler = async function(event, context) {
    console.log('Received event:', JSON.stringify(event, null, 4));

    const payload = JSON.parse(event.Records[0].Sns.Message);

    const dynamo = new AWS.DynamoDB();
    const params = {
        TableName: "Messages",
        Item: {
            "User": {
                S: payload.user
            },
            "Timestamp": {
                N: payload.timestamp.toString()
            },
            "Conversation": {
                S: payload.conversation
            },
            "Message": {
                S: payload.message
            }
        }
    }
    await dynamo.putItem(params).promise();
    console.log('Published message:', payload);
    return null;
};