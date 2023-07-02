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

provider "aws" {
  region                      = "eu-central-1"
  shared_credentials_files    = [var.credentials_path]
  alias                       = "eu"
}

provider "aws" {
  region                      = "us-east-1"
  shared_credentials_files    = [var.credentials_path]
  alias                       = "us"
}

provider "aws" {
  region                      = "ap-southeast-1"
  shared_credentials_files    = [var.credentials_path]
  alias                       = "ap"
}

# ---------------------
# Initial Configuration
# ---------------------

# ---- deployed in every region

module "init_vpc_eu" {
  source           = "./modules/vpc"
  count            = var.init ? 1 : 0
  providers = {
    aws = aws.eu
  }
}

module "init_vpc_us" {
  source           = "./modules/vpc"
  count            = var.init ? 1 : 0
  providers = {
    aws = aws.us
  }
}

module "init_vpc_ap" {
  source           = "./modules/vpc"
  count            = var.init ? 1 : 0
  providers = {
    aws = aws.ap
  }
}

# ----

# ---- export output variables to config file

resource "local_file" "output_vpc_config_eu" {
  filename  = "config/vpc_eu-central-1.json"
  count     = var.init ? 1 : 0
  content   = jsonencode(module.init_vpc_eu)
}

resource "local_file" "output_vpc_config_us" {
  filename  = "config/vpc_us-east-1.json"
  count     = var.init ? 1 : 0
  content   = jsonencode(module.init_vpc_us)
}

resource "local_file" "output_vpc_config_ap" {
  filename  = "config/vpc_ap-southeast-1.json"
  count     = var.init ? 1 : 0
  content   = jsonencode(module.init_vpc_ap)
}

# ----

module "init_sns" {
  source            = "./modules/sns"
  count             = var.init ? 1 : 0
  providers = {
    aws = aws.eu
  }
}

module "init_sqs_us" {
  source            = "./modules/sqs"
  count             = var.init ? 1 : 0
  providers = {
    aws = aws.us
  }
}

module "init_sqs_ap" {
  source            = "./modules/sqs"
  count             = var.init ? 1 : 0
  providers = {
    aws = aws.ap
  }
}

# first we need to create a peering connection from reader
module "init_vpc_peering_us" {
  source           = "./modules/vpc/peering"
  count            = var.init ? 1 : 0
  peering_region   = "eu-central-1"
  in_reader_region = true
  providers = {
    aws = aws.us
  }
}

module "init_vpc_peering_ap" {
  source           = "./modules/vpc/peering"
  count            = var.init ? 1 : 0
  peering_region   = "eu-central-1"
  in_reader_region = true
  providers = {
    aws = aws.ap
  }
}

module "init_vpc_peering_writer_to_reader_us" {
  source           = "./modules/vpc/peering"
  count            = var.init ? 1 : 0
  peering_region   = "us-east-1" 
  providers = {
    aws = aws.writer
  }
}

module "init_vpc_peering_writer_to_reader_ap" {
  source           = "./modules/vpc/peering"
  count            = var.init ? 1 : 0
  peering_region   = "ap-southeast-1" 
  providers = {
    aws = aws.writer
  }
}

# ---- deployed only in writer and reader regions

module "init_dynamo" {
  source            = "./modules/dynamo"
  count             = var.init ? 1 : 0
  reader            = var.reader
  providers = {
    aws = aws.writer
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

# ----

# ---------------
# Main Deployment
# ---------------

module "create_vpc_endpoint_writer_sns" {
  source            = "./modules/vpc/endpoints"
  count             = var.post_storage == "cache" ? 1 : 0
  service           = "sns"
  providers = {
    aws = aws.writer
  }
}

module "create_vpc_endpoint_writer_sqs" {
  source            = "./modules/vpc/endpoints"
  count             = var.post_storage == "cache" ? 1 : 0
  service           = "sqs"
  providers = {
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

module "deploy_cache" {
  source            = "./modules/cache"

  # REMINDER:
  # cache module uses multiple aws provides which conflicts with using "count" here
  # solution: pass deploy flag and the module will be the one deciding
  deploy            = var.deploy && var.post_storage == "cache" ? true : false
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