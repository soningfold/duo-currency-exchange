data "archive_file" "extract_lambda" {
  type        = "zip"
  output_path = "${path.module}/../packages/extract/function.zip"
  source_file = "${path.module}/../src/extract.py"
}

data "archive_file" "transform_lambda" {
  type        = "zip"
  output_path = "${path.module}/../packages/transform/function.zip"
  source_file = "${path.module}/../src/transform.py"
}

data "archive_file" "load_lambda" {
  type        = "zip"
  output_path = "${path.module}/../packages/load/function.zip"
  source_file = "${path.module}/../src/load.py"
}

resource "aws_lambda_function" "workflow_tasks_extract" {
  function_name    = var.extract_lambda
  source_code_hash = data.archive_file.extract_lambda.output_base64sha256
  s3_bucket        = aws_s3_bucket.code_bucket.bucket
  s3_key           = "${var.extract_lambda}/function.zip"
  role             = aws_iam_role.lambda_role.arn
  handler          = "${var.extract_lambda}.lambda_handler"
  runtime          = "python3.12"
  timeout          = var.default_timeout
  layers           = [aws_lambda_layer_version.dependencies.arn]

  depends_on = [aws_s3_object.lambda_code, aws_s3_object.lambda_layer]
}

resource "aws_lambda_function" "workflow_tasks_transform" {
  function_name    = var.transform_lambda
  source_code_hash = data.archive_file.transform_lambda.output_base64sha256
  s3_bucket        = aws_s3_bucket.code_bucket.bucket
  s3_key           = "${var.transform_lambda}/function.zip"
  role             = aws_iam_role.lambda_role.arn
  handler          = "${var.transform_lambda}.lambda_handler"
  runtime          = "python3.12"
  timeout          = var.default_timeout

  depends_on = [aws_s3_object.lambda_code]
}

resource "aws_lambda_function" "workflow_tasks_load" {
  function_name    = var.load_lambda
  source_code_hash = data.archive_file.load_lambda.output_sha256
  s3_bucket        = aws_s3_bucket.code_bucket.bucket
  s3_key           = "${var.load_lambda}/function.zip"
  role             = aws_iam_role.lambda_role.arn
  handler          = "${var.load_lambda}.lambda_handler"
  runtime          = "python3.12"
  timeout          = var.default_timeout

  depends_on = [aws_s3_object.lambda_code]
}

