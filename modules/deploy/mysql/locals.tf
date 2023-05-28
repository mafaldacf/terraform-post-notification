locals {
    # Mandatory variables
    json_vpc_eu = file("${path.root}/config/vpc_eu-central-1.json")
    json_vpc_us = file("${path.root}/config/vpc_us-east-1.json")
    vpc_config = {
        "eu-central-1" = jsondecode(local.json_vpc_eu)[0]
        "us-east-1"    = jsondecode(local.json_vpc_us)[0]
    }
}