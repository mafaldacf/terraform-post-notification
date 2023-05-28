terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

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
  count                              = var.deploy == true ? 1 : 0
  provider                           = aws.writer
  global_replication_group_id_suffix = "antipode-lambda"
  primary_replication_group_id       = aws_elasticache_replication_group.primary[0].id
}

resource "aws_elasticache_subnet_group" "writer" {
  count       = var.deploy == true ? 1 : 0
  provider    = aws.writer
  name        = "antipode-lambda-writer"
  subnet_ids  = local.subnet_ids[data.aws_region.current.name]
}

resource "aws_elasticache_subnet_group" "reader" {
  count       = var.deploy == true ? 1 : 0
  provider    = aws.reader
  name        = "antipode-lambda-reader"
  subnet_ids  = local.subnet_ids[data.aws_region.current.name]
}

resource "aws_elasticache_replication_group" "primary" {
  count                         = var.deploy == true ? 1 : 0
  provider                      = aws.writer
  replication_group_id          = "antipode-lambda-writer"
  description                   = "Primary elasticache cluster in writer region"
  node_type                     = "cache.r5.large"
  port                          = 6379
  snapshot_retention_limit      = 0
  apply_immediately             = true
  num_cache_clusters            = 2
  subnet_group_name             = aws_elasticache_subnet_group.writer[0].name
  multi_az_enabled              = true 
  automatic_failover_enabled    = true
}

resource "aws_elasticache_replication_group" "secondary" {
  count                         = var.deploy == true ? 1 : 0
  provider                      = aws.reader
  replication_group_id          = "antipode-lambda-reader"
  description                   = "Secondary elasticache cluster in reader region"
  global_replication_group_id   = aws_elasticache_global_replication_group.global[0].global_replication_group_id
  port                          = 6379
  snapshot_retention_limit      = 0
  apply_immediately             = true
  num_cache_clusters            = 2
  subnet_group_name             = aws_elasticache_subnet_group.reader[0].name
  multi_az_enabled              = true 
  automatic_failover_enabled    = true
}