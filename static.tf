resource "aws_s3_bucket" "warbler" {
  bucket = "warbler"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

output "s3_bucket_endpoint" {
  value = aws_s3_bucket.warbler.website_endpoint
}

resource "aws_s3_bucket_object" "static_html_object" {
  for_each = fileset("static", "*.html")
  key = each.key

  bucket = "warbler"
  source = "static/${each.key}"
  acl    = "public-read"

  content_type = "text/html"

  etag = filemd5("static/${each.key}")
}

resource "aws_s3_bucket_object" "static_js" {
  for_each = fileset("static", "*.js")
  key = each.key

  bucket = "warbler"
  source = "static/${each.key}"
  acl    = "public-read"

  content_type = "text/javascript"

  etag = filemd5("static/${each.key}")
}
