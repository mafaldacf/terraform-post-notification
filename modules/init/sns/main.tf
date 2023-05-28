terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

# --------------
# Main Resources
# --------------

resource "aws_sns_topic" "notifications" {
  name        = local.topic_name
  fifo_topic  = false
}

output "sns-topic-name" {
  value = aws_sns_topic.notifications.name
}