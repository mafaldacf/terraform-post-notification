terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

# NOTE:
# Both providers are defined here for simplicity
# One module invocation => deploying resources in both regions

provider "aws" {
  region                      = var.writer
  shared_credentials_files    = [var.credentials_path]
  alias                       = "writer"
}

provider "aws" {
  region                      = var.reader
  shared_credentials_files    = [var.credentials_path]
  alias                       = "reader"
}

data "aws_region" "current" {
  provider = aws
}

# --------------------
# Deployment Resources
# --------------------

resource "aws_elasticache_global_replication_group" "global" {
  provider                           = aws.writer
  count                              = var.deploy == true ? 1 : 0
  global_replication_group_id_suffix = local.global_cluster_name
  primary_replication_group_id       = aws_elasticache_replication_group.primary[0].id
}

resource "aws_elasticache_subnet_group" "writer" {
  provider    = aws.writer
  count       = var.deploy == true ? 1 : 0
  name        = "${local.elasticache_subnet_name}-writer"
  subnet_ids  = local.vpc_config[data.aws_region.current.name].subnet_ids
}

resource "aws_elasticache_subnet_group" "reader" {
  provider    = aws.reader
  count       = var.deploy == true ? 1 : 0
  name        = "${local.elasticache_subnet_name}-reader"
  subnet_ids  = local.vpc_config[data.aws_region.current.name].subnet_ids[0]
}

resource "aws_elasticache_replication_group" "primary" {
  provider                      = aws.writer
  count                         = var.deploy == true ? 1 : 0
  replication_group_id          = "${local.global_cluster_name}-writer"
  description                   = "Primary elasticache cluster in writer region"
  node_type                     = local.node_type
  port                          = local.port
  snapshot_retention_limit      = 0
  apply_immediately             = true
  num_cache_clusters            = 2
  subnet_group_name             = aws_elasticache_subnet_group.writer[0].name
  multi_az_enabled              = true 
  automatic_failover_enabled    = true
}

resource "aws_elasticache_replication_group" "secondary" {
  provider                      = aws.reader
  count                         = var.deploy == true ? 1 : 0
  replication_group_id          = "${local.global_cluster_name}-reader"
  description                   = "Secondary elasticache cluster in reader region"
  global_replication_group_id   = aws_elasticache_global_replication_group.global[0].global_replication_group_id
  port                          = local.port
  snapshot_retention_limit      = 0
  apply_immediately             = true
  num_cache_clusters            = 2
  subnet_group_name             = aws_elasticache_subnet_group.reader[0].name
  multi_az_enabled              = true 
  automatic_failover_enabled    = true
}