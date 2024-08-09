resource "aws_iam_role" "lambda_role" {
  name_prefix        = "role-currency-lambdas-"
  assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "sts:AssumeRole"
                ],
                "Principal": {
                    "Service": [
                        "lambda.amazonaws.com"
                    ]
                }
            }
        ]
    }
    EOF
}

resource "aws_iam_role" "iam_for_sfn" {
    name_prefix        = "role-currency-sfn-"
    assume_role_policy = data.aws_iam_policy_document.state_machine_assume_role_policy.json
}

resource "aws_iam_role" "iam_for_scheduler" {
  name_prefix = "role-scheduler-"
  assume_role_policy = data.aws_iam_policy_document.scheduler_assume_role_policy.json
}

data "aws_iam_policy_document" "state_machine_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
    ]
  }
}

data "aws_iam_policy_document" "scheduler_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
    ]

  }
}

data "aws_iam_policy_document" "scheduler_document" {
  statement {
    actions = ["states:StartExecution"]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "lambda_invoke_document" {
  statement {
    actions = ["lambda:InvokeFunction"]

    resources = [
        "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.extract_lambda}:*",
        "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.transform_lambda}:*",
        "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.load_lambda}:*",
        "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.extract_lambda}",
        "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.transform_lambda}",
        "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.load_lambda}"
    ]
  }
}


data "aws_iam_policy_document" "x_ray_document" {
  statement {
     actions = ["xray:PutTraceSegments",
                "xray:PutTelemetryRecords",
                "xray:GetSamplingRules",
                "xray:GetSamplingTargets"]
     resources = ["*"]
  }
}

data "aws_iam_policy_document" "s3_document" {
  statement {

    actions = ["s3:PutObject"]

    resources = [
      "${aws_s3_bucket.data_bucket.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "cw_document" {
  statement {

    actions = ["logs:CreateLogGroup"]

    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
    ]
  }

  statement {

    actions = ["logs:CreateLogStream", "logs:PutLogEvents"]

    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*:*"
    ]
  }
}

resource "aws_iam_policy" "s3_policy" {
  name_prefix = "s3-policy-currency-lambda-"
  policy      = data.aws_iam_policy_document.s3_document.json
}


resource "aws_iam_policy" "cw_policy" {
  name_prefix = "cw-policy-currency-lambda-"
  policy      = data.aws_iam_policy_document.cw_document.json
}

resource "aws_iam_policy" "lambda_invoke_policy" {
  name_prefix = "s3-policy-currency-lambda-"
  policy      = data.aws_iam_policy_document.lambda_invoke_document.json
}

resource "aws_iam_policy" "xray_policy" {
  name_prefix = "s3-policy-currency-lambda-"
  policy      = data.aws_iam_policy_document.x_ray_document.json
}

resource "aws_iam_policy" "scheduler_policy" {
  name_prefix = "scheduler-policy-"
  policy = data.aws_iam_policy_document.scheduler_document.json
}

resource "aws_iam_role_policy_attachment" "scheduler_policy_attachment" {
  role       = aws_iam_role.iam_for_scheduler.name
  policy_arn = aws_iam_policy.scheduler_policy.arn
}

resource "aws_iam_role_policy_attachment" "sfn_lambda_invoke_policy_attachment" {
  role       = aws_iam_role.iam_for_sfn.name
  policy_arn = aws_iam_policy.lambda_invoke_policy.arn
}

resource "aws_iam_role_policy_attachment" "sfn_xray_policy_attachment" {
  role       = aws_iam_role.iam_for_sfn.name
  policy_arn = aws_iam_policy.xray_policy.arn
}


resource "aws_iam_role_policy_attachment" "lambda_s3_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_cw_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.cw_policy.arn
}