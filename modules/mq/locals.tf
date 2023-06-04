locals {
  # Dynamic locals
  vpc_config = {
      "eu-central-1" = jsondecode(file("${path.root}/config/autogen/vpc_eu-central-1.json"))[0]
      "us-east-1"    = jsondecode(file("${path.root}/config/autogen/vpc_us-east-1.json"))[0]
  }
}