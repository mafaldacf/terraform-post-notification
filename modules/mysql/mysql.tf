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

 resource "aws_db_parameter_group" "aurora_parameter_group" {
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
  engine_version            = "5.7.mysql_aurora.2.07.1"
  database_name             = "antipode"
}

resource "aws_rds_cluster" "writer" {
  provider                  = aws.writer
  engine                    = "aurora-mysql"
  engine_version            = "5.7.mysql_aurora.2.07.1"
  cluster_identifier        = "antipode-lambda-eu"
  master_username           = "antipode"
  master_password           = "antipode"
  database_name             = "antipode"
}

resource "aws_rds_cluster_instance" "writer_instance" {
  provider                = aws.writer
  engine                  = aws_rds_global_cluster.mysql_cluster.engine
  engine_version          = aws_rds_global_cluster.mysql_cluster.engine_version
  identifier              = "${aws_rds_cluster.writer.cluster_identifier}-instance-1"
  cluster_identifier      = aws_rds_cluster.writer.id
  instance_class          = "db.r5.large"
  db_parameter_group_name = aws_db_parameter_group.aurora_parameter_group.name
}

resource "aws_rds_cluster_instance" "reader_instance" {
  provider                = aws.writer
  engine                  = aws_rds_global_cluster.mysql_cluster.engine
  engine_version          = aws_rds_global_cluster.mysql_cluster.engine_version
  identifier              = "${aws_rds_cluster.writer.cluster_identifier}-instance-1-${var.writer}-a"
  cluster_identifier      = aws_rds_cluster.writer.id
  instance_class          = "db.r5.large"
  db_parameter_group_name = aws_db_parameter_group.aurora_parameter_group.name
}