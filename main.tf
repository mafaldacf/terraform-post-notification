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
  source           = "./modules/ec2"
  count            = var.init ? 1 : 0
  providers = {
    aws = aws.writer
  }
}

# ------------------------
# Initialize AWS Resources
# ------------------------

module "init_vpc_writer" {
  source           = "./modules/vpc"
  count            = var.init ? 1 : 0
  providers = {
    aws = aws.writer
  }
}

module "init_vpc_reader" {
  source           = "./modules/vpc"
  count            = var.init ? 1 : 0
  providers = {
    aws = aws.reader
  }
}

# first we need to create a peering connection from reader
module "init_vpc_peering_reader" {
  source           = "./modules/vpc/peering"
  count            = var.init ? 1 : 0
  peering_region   = var.writer
  in_reader_region = true
  providers = {
    aws = aws.reader
  }
}

module "init_vpc_peering_writer" {
  source           = "./modules/vpc/peering"
  count            = var.init ? 1 : 0
  peering_region   = var.reader 
  providers = {
    aws = aws.writer
  }
}

module "init_dynamo" {
  source            = "./modules/dynamo"
  count             = var.init ? 1 : 0
  reader            = var.reader
  providers = {
    aws = aws.writer
  }
}

module "init_sns" {
  source            = "./modules/sns"
  count             = var.init ? 1 : 0
  providers = {
    aws = aws.writer
  }
}

module "init_sqs" {
  source            = "./modules/sqs"
  count             = var.init ? 1 : 0
  providers = {
    aws = aws.reader
  }
}

module "init_s3_reader" {
  source            = "./modules/s3"
  count             = var.init ? 1 : 0
  region            = var.reader
  providers = {
    aws = aws.reader
  }
}

module "init_s3_writer" {
  source            = "./modules/s3"
  count             = var.init ? 1 : 0

  # create a replication rule from writer to reader
  replication_rule  = true 
  region            = var.writer
  secondary_region  = var.reader

  providers = {
    aws = aws.writer
  }
}

# ---------------------
# Deploy AWS Resources
# ---------------------

module "create_vpc_endpoint_writer" {
  source            = "./modules/vpc/endpoints"
  for_each          = toset(var.post_storage == "dynamo" && var.notification_storage == "sns" ? ["dynamo", "sns"] : [])
  service           = each.value
  providers = {
    aws = aws.writer
  }
}

module "create_vpc_endpoint_reader" {
  source            = "./modules/vpc/endpoints"
  service           = "sqs"
  providers         = {
    aws = aws.reader
  }
}

module "deploy_ec2_writer" {
  source            = "./modules/ec2"
  count             = var.deploy && var.rendezvous ? 1 : 0
  providers = {
    aws = aws.writer
  }
}

module "deploy_ec2_reader" {
  source            = "./modules/ec2"
  count             = var.deploy && var.rendezvous ? 1 : 0
  providers = {
    aws = aws.reader
  }
}

module "deploy_mq_writer" {
  source            = "./modules/mq"
  count             = var.deploy && var.notification_storage == "mq" ? 1 : 0
  providers = {
    aws = aws.writer
  }
}

module "deploy_mq_reader" {
  source            = "./modules/mq"
  count             = var.deploy && var.notification_storage == "mq" ? 1 : 0
  providers = {
    aws = aws.reader
  }
}

module "deploy_redis" {
  source            = "./modules/redis"

  # REMINDER:
  # redis module uses multiple aws provides which conflicts with using "count" here
  # solution: pass deploy flag and the module will be the one deciding
  deploy            = var.deploy && var.post_storage == "redis" ? true : false
  credentials_path  = var.credentials_path
  writer            = var.writer
  reader            = var.reader
}

module "deploy_mysql" {
  source            = "./modules/mysql"
  deploy            = var.post_storage == "mysql" ? true : false
  
  # REMINDER:
  # mysql module uses multiple aws provides which conflicts with using "count" here
  # solution: pass deploy flag and the module will be the one deciding
  credentials_path  = var.credentials_path
  writer            = var.writer
  reader            = var.reader
}

# --------------------------------------
# Export output variables to config file
# ---------------------------------------

resource "local_file" "output_vpc_writer_config" {
  filename  = "config/autogen/vpc_${var.writer}.json"
  count     = var.init ? 1 : 0
  content   = jsonencode(module.init_vpc_writer)
}

resource "local_file" "output_vpc_reader_config" {
  filename  = "config/autogen/vpc_${var.reader}.json"
  count     = var.init ? 1 : 0
  content   = jsonencode(module.init_vpc_reader)
}

resource "local_file" "output_ec2_writer_config" {
  filename  = "config/autogen/ec2_${var.writer}.json"
  count     = var.deploy && var.rendezvous ? 1 : 0
  content   = jsonencode(module.deploy_ec2_writer)
}

resource "local_file" "output_ec2_reader_config" {
  filename  = "config/autogen/ec2_${var.reader}.json"
  count     = var.deploy && var.rendezvous ? 1 : 0
  content   = jsonencode(module.deploy_ec2_reader)
}

resource "local_file" "output_mq_writer_config" {
  filename  = "config/autogen/mq_${var.writer}.json"
  count     = var.deploy && var.notification_storage == "mq" ? 1 : 0
  content   = jsonencode(module.deploy_mq_writer)
}

resource "local_file" "output_mq_reader_config" {
  filename  = "config/autogen/mq_${var.reader}.json"
  count     = var.deploy && var.notification_storage == "mq" ? 1 : 0
  content   = jsonencode(module.deploy_mq_reader)
}