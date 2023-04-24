terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

data "aws_region" "current" {
    provider = aws
}

# --------------------
# Deployment Resources
# --------------------

resource "aws_instance" "rendezvous_instance" {
    ami                         = local.config[data.aws_region.current.name].ami
    instance_type               = "t2.micro"
    key_name                    = local.config[data.aws_region.current.name].rsa_key_pair

    subnet_id                   = local.config[data.aws_region.current.name].subnet_id
    vpc_security_group_ids      = [local.config[data.aws_region.current.name].sg_id]
    associate_public_ip_address = true

    tags = {
        Name = "rendezvous-lambda"
    }
}