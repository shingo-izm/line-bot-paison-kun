resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = aws_iam_role.lambda_exec.arn
  handler       = var.handler
  runtime       = var.runtime
  architectures = ["arm64"]

  filename         = var.artifact_zip
  source_code_hash = filebase64sha256(var.artifact_zip)

  timeout     = var.timeout
  memory_size = var.memory_size
}

resource "aws_lambda_permission" "allow_scheduler" {
  statement_id  = "AllowSchedulerInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "scheduler.amazonaws.com"
  source_arn    = aws_scheduler_schedule.monthly.arn
}
