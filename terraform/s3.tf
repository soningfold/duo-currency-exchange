resource "aws_s3_bucket" "data_bucket" {
  bucket_prefix = "nc-de-currency-data-"
}

resource "aws_s3_bucket" "code_bucket" {
  bucket_prefix = "nc-de-currency-code-"
}

resource "aws_s3_object" "lambda_code" {
  for_each = toset([var.extract_lambda, var.transform_lambda, var.load_lambda])
  bucket   = aws_s3_bucket.code_bucket.bucket
  key      = "${each.key}/function.zip"
  source   = "${path.module}/../packages/${each.key}/function.zip"
  etag     = filemd5("${path.module}/../packages/${each.key}/function.zip")
}

resource "aws_s3_object" "lambda_layer" {
  bucket = aws_s3_bucket.code_bucket.bucket
  key    = "layer/layer.zip"
  source = data.archive_file.layer_code.output_path
  etag   = filemd5(data.archive_file.layer_code.output_path)
  depends_on = [ data.archive_file.layer_code ]
}