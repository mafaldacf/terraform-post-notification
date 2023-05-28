locals {
  json_config = file("${path.root}/config/config.json")
  sns_config = jsondecode(local.json_config)["sns"]
}