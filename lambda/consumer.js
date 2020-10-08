console.log('Loading function');

exports.handler = function(event, context, callback) {
    console.log('Received event:', JSON.stringify(event, null, 4));

    let message = event.Records[0].Sns.Message;
    console.log('Message received from SNS:', message);
    callback(null, "Success");
};