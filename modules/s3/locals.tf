locals {
    # Dynamic locals
    s3_config = jsondecode(file("${path.root}/config/config.json"))["s3"]
}