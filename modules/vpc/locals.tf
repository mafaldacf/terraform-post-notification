locals {
    vpc_cidr_blocks = {
        eu-central-1 = "50.0.0.0/16",
        us-east-1    = "51.0.0.0/16"
    }
    subnet_cidr_blocks = {
        eu-central-1    = ["50.0.0.0/20", "50.0.16.0/20"]
        us-east-1       = ["51.0.0.0/20", "51.0.16.0/20"]
    }
    rendezvous_port = "8000"

    # our ip -> optional for secure SSH, otherwise use "0.0.0.0/0"
    ssh_cidr = "95.94.226.172/32"
}