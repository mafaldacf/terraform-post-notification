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
    ami                         = local.instance_settings.ami[data.aws_region.current.name]
    instance_type               = local.instance_type
    key_name                    = local.instance_settings.rsa_keypair_name[data.aws_region.current.name]

    subnet_id                   = local.vpc_config[data.aws_region.current.name].subnet_ids[0]
    vpc_security_group_ids      = [local.vpc_config[data.aws_region.current.name].security_group_id]
    associate_public_ip_address = true

    tags = {
      Name = local.instance_name
    }
}