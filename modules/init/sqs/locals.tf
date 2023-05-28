locals {
  json_config = file("${path.root}/config/config.json")
  sqs_config = jsondecode(local.json_config)["sqs"]
}