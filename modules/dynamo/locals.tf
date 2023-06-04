locals {
  # Dynamic locals
  tables_config = jsondecode(file("${path.root}/config/config.json"))["dynamo"]["tables_keys"]
}