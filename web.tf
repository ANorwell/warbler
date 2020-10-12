module "lambda_web" {
  source = "./modules/lambda-function"

  name = "web"
  filename = "lambda/web.zip"
  handler = "web.handler"
  runtime = "nodejs12.x"

  iam_role = aws_iam_role.lambda_role
}

resource "aws_api_gateway_rest_api" "web_api" {
  name        = "web-api"
  description = "API gateway for warbler"
}

resource "aws_api_gateway_resource" "proxy" {
   rest_api_id = aws_api_gateway_rest_api.web_api.id
   parent_id   = aws_api_gateway_rest_api.web_api.root_resource_id
   path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
   rest_api_id   = aws_api_gateway_rest_api.web_api.id
   resource_id   = aws_api_gateway_resource.proxy.id
   http_method   = "ANY"
   authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
   rest_api_id = aws_api_gateway_rest_api.web_api.id
   resource_id = aws_api_gateway_method.proxy.resource_id
   http_method = aws_api_gateway_method.proxy.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = module.lambda_web.lambda.invoke_arn
}

resource "aws_api_gateway_method" "proxy_root" {
   rest_api_id   = aws_api_gateway_rest_api.web_api.id
   resource_id   = aws_api_gateway_rest_api.web_api.root_resource_id
   http_method   = "ANY"
   authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
   rest_api_id = aws_api_gateway_rest_api.web_api.id
   resource_id = aws_api_gateway_method.proxy_root.resource_id
   http_method = aws_api_gateway_method.proxy_root.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = module.lambda_web.lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "web_test" {
   depends_on = [
     aws_api_gateway_integration.lambda,
     aws_api_gateway_integration.lambda_root
   ]

   rest_api_id = aws_api_gateway_rest_api.web_api.id
   stage_name  = "test"
}

resource "aws_lambda_permission" "apigw" {
   statement_id  = "AllowAPIGatewayInvoke"
   action        = "lambda:InvokeFunction"
   function_name = module.lambda_web.lambda.function_name
   principal     = "apigateway.amazonaws.com"

   # The "/*/*" portion grants access from any method on any resource
   # within the API Gateway REST API.
   source_arn = "${aws_api_gateway_rest_api.web_api.execution_arn}/*/*"
}

output "base_url" {
  value = aws_api_gateway_deployment.web_test.invoke_url
}