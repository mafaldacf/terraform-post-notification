provider "aws" {
  region                      = var.writer_region
  shared_credentials_files    = [var.credentials_path]
  alias                       = "writer_region"
}

provider "aws" {
  region                      = var.reader_region
  shared_credentials_files    = [var.credentials_path]
  alias                       = "reader_region"
}

# --------------
# Main Resources
# --------------

module "vpc_writer_region" {
  source                = "./modules/vpc"
  count                 = var.create_main_resources && var.create_main_resources_vpcs ? 1 : 0
  providers = {
    aws = aws.writer_region
  }
}

module "vpc_reader_region" {
  source                = "./modules/vpc"
  count                 = var.create_main_resources && var.create_main_resources_vpcs ? 1 : 0
  providers = {
    aws = aws.reader_region
  }
}

module "dynamo" {
  source                = "./modules/dynamo"
  count                 = var.create_main_resources && var.create_main_resources_dynamo ? 1 : 0
  reader_region         = var.reader_region
  providers = {
    aws = aws.writer_region
  }
}

module "sns" {
  source                = "./modules/sns"
  count                 = var.create_main_resources && var.create_main_resources_sns ? 1 : 0
  providers = {
    aws = aws.writer_region
  }
}

module "sqs" {
  source                = "./modules/sqs"
  count                 = var.create_main_resources && var.create_main_resources_sqs ? 1 : 0
  providers = {
    aws = aws.reader_region
  }
}

module "s3_reader_region" {
  source                    = "./modules/s3"
  count                     = var.create_main_resources && var.create_main_resources_s3 ? 1 : 0
  providers = {
    aws = aws.reader_region
  }
}

module "s3_writer_region" {
  source                    = "./modules/s3"
  count                     = var.create_main_resources && var.create_main_resources_s3 ? 1 : 0

  # replication rule from writer to reader
  create_s3_replication     = true 
  writer_region             = var.writer_region
  reader_region             = var.reader_region

  providers = {
    aws = aws.writer_region
  }
}

# --------------------
# Deployment Resources
# --------------------

module "ec2_writer_reagion" {
  source                = "./modules/ec2"
  count                 = var.create_rendezvous_ec2_instances ? 1 : 0
  providers = {
    aws = aws.writer_region
  }
}

module "ec2_reader_reagion" {
  source                = "./modules/ec2"
  count                 = var.create_rendezvous_ec2_instances ? 1 : 0
  providers = {
    aws = aws.reader_region
  }
}

module "vpc_endpoints_writer_region" {
  source                = "./modules/vpc/endpoints"
  for_each              = var.create_vpc_endpoints ? toset(var.endpoints_services_writer_region) : []
  service               = each.value
  providers = {
    aws = aws.writer_region
  }
}

module "vpc_endpoints_reader_region" {
  source                = "./modules/vpc/endpoints"
  for_each              = var.create_vpc_endpoints ? toset(var.endpoints_services_reader_region) : []
  service               = each.value
  providers = {
    aws = aws.reader_region
  }
}