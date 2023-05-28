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

resource "aws_sqs_queue" "evaluation" {
    name        = local.sqs_config.queue_name
    fifo_queue  = false
}