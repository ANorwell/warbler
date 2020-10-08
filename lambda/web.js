exports.handler = function(event, context, callback) {
  console.log('Received event:', JSON.stringify(event, null, 4));

  let response = {
    statusCode: 200,
    headers: {
      'Content-Type': 'text/html; charset=utf-8',
    },
    body: '<p>Hello world!</p>',
  }
  callback(null, response)
};