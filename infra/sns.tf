// SNS topic for Auto Scaling notifications
resource "aws_sns_topic" "autoscaling_notifications" {
  name = "autoscaling-notifications"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.autoscaling_notifications.arn
  protocol  = "email"
  endpoint  = "antoniogarci0309@gmail.com"
}