output "channel_id" {
  description = "생성된 Slack 채널의 ID"
  value       = slack_channel.my_channel.id
}

output "app_token" {
  description = "생성된 Slack 앱의 토큰 (실제 사용 시 적절한 토큰 변수 사용)"
  value       = slack_app.my_app.token 
  sensitive   = true  # 토큰은 민감한 정보이므로 sensitive로 설정
}