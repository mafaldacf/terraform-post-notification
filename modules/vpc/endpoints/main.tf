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

resource "aws_vpc_endpoint" "gateway_dynamodb" {
  count               = var.service == "dynamo" ? 1 : 0
  vpc_id              = local.config[data.aws_region.current.name].vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  vpc_endpoint_type   = "Gateway"
  route_table_ids     = [local.config[data.aws_region.current.name].route_table_id]

  tags = {
    Name = var.service
  }
}

resource "aws_vpc_endpoint" "interface_sns_or_sqs" {
  count               = var.service == "sns" || var.service == "sqs" ? 1 : 0
  vpc_id              = local.config[data.aws_region.current.name].vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${var.service}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [local.config[data.aws_region.current.name].subnet_id]
  security_group_ids  = [local.config[data.aws_region.current.name].security_group_id]

  tags = {
    Name = var.service
  }
}