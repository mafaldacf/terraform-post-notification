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

module "test" {
  source           = "./modules/deploy/ec2"
  count            = var.init ? 1 : 0
  providers = {
    aws = aws.writer
  }
}

# -----------------------------
# Initialize Main AWS Resources
#   (should only happen once)
# -----------------------------

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

# Store output from "init_vpc_writer" module into a json file in "config" directory
resource "local_file" "output_vpc_writer_config" {
  filename  = "config/vpc_${var.writer}.json"
  count     = var.init ? 1 : 0
  content   = jsonencode(module.init_vpc_writer)
}

# Store output from "init_vpc_reader" module into a json file in "config" directory
resource "local_file" "output_vpc_reader_config" {
  filename  = "config/vpc_${var.reader}.json"
  count     = var.init ? 1 : 0
  content   = jsonencode(module.init_vpc_reader)
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

# ---------------------
# Deploy AWS Resources
# ---------------------

module "create_vpc_endpoint_writer" {
  source            = "./modules/deploy/vpc"
  for_each          = toset(var.post_storage == "dynamo" ? ["dynamo", "sns"] : ["sns"])
  service           = each.value
  providers = {
    aws = aws.writer
  }
}

module "create_vpc_endpoint_reader" {
  source            = "./modules/deploy/vpc"
  for_each          = toset(var.post_storage == "dynamo" ? ["dynamo", "sqs"] : ["sqs"])
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

# Store output from "deploy_ec2_writer" module into a json file in "config" directory
resource "local_file" "output_ec2_writer_config" {
  filename  = "config/ec2_${var.writer}.json"
  count     = var.init ? 1 : 0
  content   = jsonencode(module.deploy_ec2_writer)
}

module "deploy_ec2_reader" {
  source            = "./modules/deploy/ec2"
  count             = var.deploy && var.rendezvous ? 1 : 0
  providers = {
    aws = aws.reader
  }
}

# Store output from "deploy_ec2_reader" module into a json file in "config" directory
resource "local_file" "output_ec2_reader_config" {
  filename  = "config/ec2_${var.reader}.json"
  count     = var.init ? 1 : 0
  content   = jsonencode(module.deploy_ec2_reader)
}

module "deploy_redis" {
  source            = "./modules/deploy/redis"

  # redis module uses multiple aws provides which conflicts with using "count" here
  # solution: pass deploy flag and the module will be the one deciding
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