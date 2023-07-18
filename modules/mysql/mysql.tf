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

# --------------------
# Deployment Resources
# --------------------

 resource "aws_db_parameter_group" "mysql_parameter_group_primary_region" {
  count       = var.deploy == true ? 1 : 0
  provider    = aws.writer
  name        = "antipode-lambda-2"
  family      = "aurora-mysql5.7"
  parameter {
    name  = "max_connections"
    value = local.mysql_max_connections
  }
}

resource "aws_db_parameter_group" "mysql_parameter_group_secondary_region" {
  count       = var.deploy == true ? 1 : 0
  provider    = aws.reader
  name        = "antipode-lambda-2"
  family      = "aurora-mysql5.7"
  parameter {
    name  = "max_connections"
    value = local.mysql_max_connections
  }
}

resource "aws_rds_global_cluster" "global_database" {
  count                     = var.deploy == true ? 1 : 0
  provider                  = aws.writer
  global_cluster_identifier = "antipode-lambda"
  engine                    = "aurora-mysql"
  engine_version            = "5.7.mysql_aurora.2.07.1"
  database_name             = "antipode"
  
}

resource "aws_rds_cluster" "primary_cluster" {
  count                     = var.deploy == true ? 1 : 0
  provider                  = aws.writer
  global_cluster_identifier = aws_rds_global_cluster.global_database[0].id
  engine                    = aws_rds_global_cluster.global_database[0].engine
  engine_version            = aws_rds_global_cluster.global_database[0].engine_version
  availability_zones        = ["${var.writer}a"]
  cluster_identifier        = "antipode-lambda-${substr(var.writer, 0, 2)}"
  master_username           = "antipode"
  master_password           = "antipode"
  database_name             = "antipode"
  db_subnet_group_name      = "default"
  skip_final_snapshot       = true
}

resource "aws_rds_cluster_instance" "writer_instance" {
  count                         = var.deploy == true ? 1 : 0
  provider                      = aws.writer
  cluster_identifier            = aws_rds_cluster.primary_cluster[0].id
  engine                        = aws_rds_global_cluster.global_database[0].engine
  engine_version                = aws_rds_global_cluster.global_database[0].engine_version
  identifier                    = "${aws_rds_cluster.primary_cluster[0].cluster_identifier}-instance"
  instance_class                = "db.r3.large"
  db_parameter_group_name       = aws_db_parameter_group.mysql_parameter_group_primary_region[0].name
  db_subnet_group_name          = "default"
  publicly_accessible           = true
  performance_insights_enabled  = false
  auto_minor_version_upgrade    = false
}


resource "aws_rds_cluster" "secondary_cluster" {
  count                     = var.deploy == true ? 1 : 0
  provider                  = aws.reader
  global_cluster_identifier = aws_rds_global_cluster.global_database[0].id
  engine                    = aws_rds_global_cluster.global_database[0].engine
  engine_version            = aws_rds_global_cluster.global_database[0].engine_version
  availability_zones        = ["${var.reader}a"]
  cluster_identifier        = "antipode-lambda-${substr(var.reader, 0, 2)}"
  db_subnet_group_name      = "default"
  skip_final_snapshot       = true
  depends_on = [
    aws_rds_cluster_instance.writer_instance
  ]
}

resource "aws_rds_cluster_instance" "reader_instance" {
  count                         = var.deploy == true ? 1 : 0
  provider                      = aws.reader
  cluster_identifier            = aws_rds_cluster.secondary_cluster[0].id
  engine                        = aws_rds_global_cluster.global_database[0].engine
  engine_version                = aws_rds_global_cluster.global_database[0].engine_version
  identifier                    = "${aws_rds_cluster.secondary_cluster[0].cluster_identifier}-instance"
  instance_class                = "db.r3.large"
  db_parameter_group_name       = aws_db_parameter_group.mysql_parameter_group_secondary_region[0].name
  db_subnet_group_name          = "default"
  publicly_accessible           = true
  performance_insights_enabled  = false
  auto_minor_version_upgrade    = false
}