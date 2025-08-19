terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

variable "region" { default = "ap-northeast-1" }
variable "function_name" { default = "monthly-schedule-task" }
# パッケージ無しの場合の暫定ハンドラ。パッケージ付与したら "com.example.MonthlyScheduleTask" に変更
variable "handler" { default = "MonthlyScheduleTask" }
# CIで作るZip（Fat JAR + service-account.json）
variable "artifact_zip" { default = "build/lambda.zip" }

provider "aws" { region = var.region }

# --- Lambda 実行ロール（CloudWatch Logs 出力可） ---
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals { type = "Service", identifiers = ["lambda.amazonaws.com"] }
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

# --- Lambda 関数 ---
resource "aws_lambda_function" "this" {
  function_name    = var.function_name
  role             = aws_iam_role.lambda_exec.arn
  handler          = var.handler
  runtime          = "java21"          # もしくは "java17"
  architectures    = ["arm64"]
  filename         = var.artifact_zip
  source_code_hash = filebase64sha256(var.artifact_zip)
  timeout          = 30
  memory_size      = 1024
}

# --- Scheduler が Invoke するためのロール（必須） ---
data "aws_iam_policy_document" "sch_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals { type = "Service", identifiers = ["scheduler.amazonaws.com"] }
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

# --- 月次スケジュール（毎月15日 09:00 JST） ---
resource "aws_scheduler_schedule" "monthly" {
  name        = "${var.function_name}-monthly"
  description = "Invoke Lambda on 15th 09:00 JST every month"
  group_name  = "default"

  schedule_expression          = "cron(0 9 15 * ? *)"
  schedule_expression_timezone = "Asia/Tokyo"  # JST を明示

  flexible_time_window { mode = "OFF" }

  target {
    arn      = aws_lambda_function.this.arn
    role_arn = aws_iam_role.sch_invoke.arn   # Scheduler 側の必須ロール
    input    = jsonencode({ message = "scheduled" })
  }
}

# --- Lambda 側に「SchedulerからのInvoke」を許可 ---
resource "aws_lambda_permission" "allow_scheduler" {
  statement_id  = "AllowSchedulerInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "scheduler.amazonaws.com"
  source_arn    = aws_scheduler_schedule.monthly.arn
}
