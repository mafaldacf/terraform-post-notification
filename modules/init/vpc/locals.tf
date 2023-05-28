locals {
  json_config = file("${path.root}/config/config.json")
  vpc_config = jsondecode(local.json_config)["vpc"]

  # User preference
  name = "antipode-mq"
  name_rendezvous = "rendezvous"
}