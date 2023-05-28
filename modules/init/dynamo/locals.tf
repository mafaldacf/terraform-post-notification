locals {
  json_config = file("${path.root}/config/config.json")
  tables_config = jsondecode(local.json_config)["dynamo"]["tables_keys"]
}