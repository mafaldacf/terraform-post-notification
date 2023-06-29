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

# -------------------------------
# VPC Peering Connections for AMQ
# -------------------------------

resource "aws_vpc_peering_connection" "amq_peering_connection" {
  count         = var.in_reader_region ? 1 : 0
  peer_owner_id = "antipode-mq-${data.aws_region.current.name}-${var.peering_region}"
  peer_vpc_id   = local.vpc_config[data.aws_region.current.name].vpc_id
  vpc_id        = local.vpc_config[var.peering_region].vpc_id
  peer_region   = var.peering_region
  auto_accept   = true
}

resource "aws_route" "destination" {
  route_table_id            = local.vpc_config[data.aws_region.current.name].route_table_id
  destination_cidr_block    = local.vpc_cidr_blocks[var.peering_region]
  vpc_peering_connection_id = aws_vpc_peering_connection.amq_peering_connection[0].id
}