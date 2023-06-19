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

//FIXME

/* resource "aws_db_parameter_group" "aurora_parameter_group" {
  name        = "antipode-lambda"
  family      = "aurora-mysql5.7"
  parameter {
    name  = "max_connections"
    value = local.mysql_max_connections
  }
}

resource "aws_rds_global_cluster" "mysql_cluster" {
  provider                  = aws.writer
  global_cluster_identifier = "antipode-lambda"
  engine                    = "aurora-mysql"
  engine_version            = "11.9"
  database_name             = "5.7.mysql_aurora.2.07.1"
}

resource "aws_rds_cluster" "writer" {
  provider                  = aws.writer
  engine                    = aws_rds_global_cluster.mysql_cluster.engine
  engine_version            = aws_rds_global_cluster.mysql_cluster.engine_version
  cluster_identifier        = "writer-cluster-"
  master_username           = "antipode"
  master_password           = "antipode"
  database_name             = "antipode"
  global_cluster_identifier = aws_rds_global_cluster.mysql_cluster.id
  db_subnet_group_name      = "default"
}

resource "aws_rds_cluster_instance" "writer" {
  provider             = aws.writer
  engine               = aws_rds_global_cluster.mysql_cluster.engine
  engine_version       = aws_rds_global_cluster.mysql_cluster.engine_version
  identifier           = "writer-cluster-instance"
  cluster_identifier   = aws_rds_cluster.primary.id
  instance_class       = "db.r5.large"
  db_subnet_group_name = "default"
}

resource "aws_rds_cluster" "secondary" {
  provider                  = aws.reader
  engine                    = aws_rds_global_cluster.mysql_cluster.engine
  engine_version            = aws_rds_global_cluster.mysql_cluster.engine_version
  cluster_identifier        = "reader-cluster"
  global_cluster_identifier = aws_rds_global_cluster.mysql_cluster.id
  skip_final_snapshot       = true
  db_subnet_group_name      = "default"

  depends_on = [
    aws_rds_cluster_instance.writer
  ]
}

resource "aws_rds_cluster_instance" "secondary" {
  provider             = aws.reader
  engine               = aws_rds_global_cluster.mysql_cluster.engine
  engine_version       = aws_rds_global_cluster.mysql_cluster.engine_version
  identifier           = "reader-cluster-instance"
  cluster_identifier   = aws_rds_cluster.secondary.id
  instance_class       = "db.r5.large"
  db_subnet_group_name = "default"
} */