locals {
  # Dynamic locals
  sns_config = jsondecode(file("${path.root}/config/config.json"))["sns"]
}