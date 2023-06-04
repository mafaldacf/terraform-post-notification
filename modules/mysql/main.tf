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

/* resource "aws_rds_cluster_parameter_group" "aurora_parameter_group" {
  name        = "aurora-mysql-parameter-group"
  family      = "aurora-mysql5.7"

  parameter {
    name  = "max_connections"
    value = local.mysql_config["max_connections"]
  }
}

resource "aws_rds_cluster" "primary_cluster" {
  cluster_identifier            = "antipode-lambda-${var.writer}"
  engine                        = "aurora-mysql"
  engine_version                = "5.7.mysql_aurora.2.11.1"
  database_name                 = "antipode"
  master_username               = "antipode"
  master_password               = "antipode"
  backup_retention_period       = 7
  preferred_backup_window       = "00:00-01:00"
  preferred_maintenance_window  = "sun:03:00-sun:04:00"
  deletion_protection           = true
  copy_tags_to_snapshot         = true

  db_subnet_group_name = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids = [
    aws_security_group.allow_all.id,
  ]

  scaling_configuration {
    auto_pause                   = true
    max_capacity                 = 2
    min_capacity                 = 2
    seconds_until_auto_pause     = 300
    timeout_action               = "ForceApplyCapacityChange"
  }
}

resource "aws_rds_global_cluster" "global_cluster" {
  global_cluster_identifier     = "antipode-lambda"
  source_db_cluster_identifier  = aws_rds_cluster.primary_cluster.id
  engine                        = "aurora-mysql"
  engine_version                = "5.7.mysql_aurora.2.11.1"

  region {
    region_name                 = var.reader
    db_cluster_identifier       = "antipode-lambda-${var.reader}"
    reader_endpoint_enabled     = true
    deletion_protection         = true
    enable_http_endpoint        = false
  }

  vpc_security_group_ids = [
    aws_security_group.allow_all.id,
  ]
} */