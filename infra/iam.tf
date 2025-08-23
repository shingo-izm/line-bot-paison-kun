# Lambda 実行ロール（CloudWatch Logs への出力など）
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name               = "${var.function_name}-exec"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Scheduler が Lambda を Invoke するためのロール
data "aws_iam_policy_document" "sch_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sch_invoke" {
  name               = "${var.function_name}-scheduler-role"
  assume_role_policy = data.aws_iam_policy_document.sch_assume.json
}

data "aws_iam_policy_document" "sch_policy" {
  statement {
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.this.arn]
  }
}

resource "aws_iam_role_policy" "sch_invoke" {
  name   = "${var.function_name}-scheduler-invoke"
  role   = aws_iam_role.sch_invoke.id
  policy = data.aws_iam_policy_document.sch_policy.json
}
