variable "function_name" {
  type    = string
  default = "monthly-schedule-task"
}

variable "handler" {
  type    = string
  default = "dev.sizumikawa.MonthlyScheduleTask"
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
  default = 128
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