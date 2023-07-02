locals {
    # dynamic locals
    vpc_config = {
        "eu-central-1" = jsondecode(file("${path.root}/config/vpc_eu-central-1.json"))[0]
        "us-east-1"    = jsondecode(file("${path.root}/config/vpc_us-east-1.json"))[0]
    }
}