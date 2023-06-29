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
# Create VPC endpoints
# --------------------

resource "aws_vpc_endpoint" "interface_sns_sqs" {
  vpc_id              = local.vpc_config[data.aws_region.current.name].vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${var.service}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [local.vpc_config[data.aws_region.current.name].subnet_ids[0]]
  security_group_ids  = [local.vpc_config[data.aws_region.current.name].security_group_id]

  tags = {
    Name = var.service
  }
}