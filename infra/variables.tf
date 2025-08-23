variable "function_name" {
  type    = string
  default = "monthly-schedule-task"
}

# パッケージ無しの場合の暫定ハンドラ。パッケージ付与したら "com.example.MonthlyScheduleTask" に変更
variable "handler" {
  type    = string
  default = "MonthlyScheduleTask"
}

# CIで作るZip（Fat JAR + service-account.json）
variable "artifact_zip" {
  type    = string
  default = "build/lambda.zip"
}

variable "runtime" {
  type    = string
  default = "java21"
}

variable "timeout" {
  type    = number
  default = 30
}

variable "memory_size" {
  type    = number
  default = 1024
}

# 月次スケジュール（cron とタイムゾーンは可変に）
variable "monthly_cron" {
  type    = string
  default = "cron(0 9 15 * ? *)"
}

variable "schedule_timezone" {
  type    = string
  default = "Asia/Tokyo"
}