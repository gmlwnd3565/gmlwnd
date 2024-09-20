variable "channel_name" {
  description = "생성할 Slack 채널의 이름"
  type        = string
}

variable "is_private" {
  description = "채널을 비공개로 생성할지 여부"
  type        = bool
  default     = false
}

variable "app_name" {
  description = "생성할 Slack 앱의 이름"
  type        = string
}