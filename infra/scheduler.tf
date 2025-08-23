resource "aws_scheduler_schedule" "monthly" {
  name        = "${var.function_name}-monthly"
  description = "Invoke Lambda monthly (JST)"
  group_name  = "default"

  schedule_expression          = var.monthly_cron
  schedule_expression_timezone = var.schedule_timezone

  flexible_time_window { mode = "OFF" }

  target {
    arn      = aws_lambda_function.this.arn
    role_arn = aws_iam_role.sch_invoke.arn
    input    = jsonencode({ message = "scheduled" })
  }
}
