locals {
    json_config = file("${path.root}/config/config.json")
    s3_config = jsondecode(local.json_config)["s3"]
}