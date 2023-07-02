locals {
    # Dynamic locals
    vpc_config = {
        "eu-central-1" = jsondecode(file("${path.root}/config/vpc_eu-central-1.json"))[0]
        "us-east-1"    = jsondecode(file("${path.root}/config/vpc_us-east-1.json"))[0]
    }
    instance_settings = jsondecode(file("${path.root}/config/config.json"))["ec2"]

    # User preference
    instance_type = "t2.micro"
    instance_name = "rendezvous"
}