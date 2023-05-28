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

# -------------------------
# Initialize Main Resources
# -------------------------

module "init_vpc_writer" {
  source           = "./modules/init/vpc"
  count            = var.init ? 1 : 0
  providers = {
    aws = aws.writer
  }
}

module "init_vpc_reader" {
  source           = "./modules/init/vpc"
  count            = var.init ? 1 : 0
  providers = {
    aws = aws.reader
  }
}

module "init_dynamo" {
  source            = "./modules/init/dynamo"
  count             = var.init ? 1 : 0
  reader            = var.reader
  providers = {
    aws = aws.writer
  }
}

module "init_sns" {
  source            = "./modules/init/sns"
  count             = var.init ? 1 : 0
  providers = {
    aws = aws.writer
  }
}

module "init_sqs" {
  source            = "./modules/init/sqs"
  count             = var.init ? 1 : 0
  providers = {
    aws = aws.reader
  }
}

module "init_s3_reader" {
  source            = "./modules/init/s3"
  count             = var.init ? 1 : 0
  providers = {
    aws = aws.reader
  }
}

module "init_s3_writer" {
  source            = "./modules/init/s3"
  count             = var.init ? 1 : 0

  # create a replication rule from writer to reader
  replication_rule  = true 
  writer            = var.writer
  reader            = var.reader

  providers = {
    aws = aws.writer
  }
}

# --------------------
# Deployment Resources
# --------------------

locals {
  vpc_endpoint_services_writer = var.post_storage == "dynamo" ? ["dynamo", "sns"] : ["sns"]
  vpc_endpoint_services_reader = var.post_storage == "dynamo" ? ["dynamo", "sqs"] : ["sqs"]
}

module "create_vpc_endpoint_writer" {
  source            = "./modules/deploy/vpc"
  for_each          = var.deploy ? toset(vpc_endpoint_services_writer) : []
  service           = each.value
  providers = {
    aws = aws.writer
  }
}

module "create_vpc_endpoint_reader" {
  source            = "./modules/deploy/vpc"
  for_each          = var.deploy ? toset(vpc_endpoint_services_reader) : []
  service           = each.value
  providers         = {
    aws = aws.reader
  }
}

module "deploy_ec2_writer" {
  source            = "./modules/deploy/ec2"
  count             = var.deploy && var.rendezvous ? 1 : 0
  providers = {
    aws = aws.writer
  }
}

module "deploy_ec2_reader" {
  source            = "./modules/deploy/ec2"
  count             = var.deploy && var.rendezvous ? 1 : 0
  providers = {
    aws = aws.reader
  }
}

module "deploy_redis" {
  source            = "./modules/deploy/redis"

  # redis module uses multiple aws provides which conflicts with using "count" here
  # solution: pass deploy flag and the module will decide if it should run or not
  deploy            = var.deploy && var.post_storage == "redis" ? true : false
  credentials_path  = var.credentials_path
  writer            = var.writer
  reader            = var.reader
}

module "deploy_mysql" {
  source            = "./modules/deploy/mysql"
  deploy            = var.post_storage == "mysql" ? true : false
  
  credentials_path  = var.credentials_path
  writer            = var.writer
  reader            = var.reader
}