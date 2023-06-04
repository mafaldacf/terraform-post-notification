locals {
  # Dynamic locals
  sqs_config = jsondecode(file("${path.root}/config/config.json"))["sqs"]
}