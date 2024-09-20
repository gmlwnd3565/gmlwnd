resource "slack_conversation" "my_channel" {
  name        = var.channel_name
  is_private  = var.is_private
}

resource "slack_app" "my_app" {
  name = var.app_name
}