terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

data "aws_region" "current" {
  provider = aws
}


# --------------
# Main Resources
# --------------

resource "aws_mq_broker" "broker" {
  broker_name               = "antipode-lambda-notifications-${data.aws_region.current.name}"
  engine_type               = "ActiveMQ"
  deployment_mode           = "SINGLE_INSTANCE"
  engine_version            = "5.16.2"
  host_instance_type        = "mq.t2.micro"
  publicly_accessible       = true
  user {
    username = "antipode"
    password = "antipode1antipode"
  }

  subnet_ids                 = [local.vpc_config[data.aws_region.current.name].subnet_ids[0]]
  security_groups            = [local.vpc_config[data.aws_region.current.name].security_group_id]
  auto_minor_version_upgrade = false

  tags = {
    Name = "antipode-lambda-notifications"
  }
}