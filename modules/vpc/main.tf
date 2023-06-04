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

# --------------------------------
# VPC configuration with 2 subnets
# --------------------------------

resource "aws_vpc" "antipode_mq" {
  cidr_block            = local.vpc_config.vpc_cidr_blocks[data.aws_region.current.name]
  enable_dns_hostnames  = true

  tags = {
    Name = "${local.name}"
  }
}

resource "aws_subnet" "antipode_mq_a" {

  vpc_id            = aws_vpc.antipode_mq.id
  cidr_block        = local.vpc_config.subnet_cidr_blocks[data.aws_region.current.name][0]
  availability_zone = "${data.aws_region.current.name}a"

  tags = {
    Name = "${local.name}-a"
  }
}

resource "aws_subnet" "antipode_mq_b" {
  vpc_id            = aws_vpc.antipode_mq.id
  cidr_block        = local.vpc_config.subnet_cidr_blocks[data.aws_region.current.name][1]
  availability_zone = "${data.aws_region.current.name}b"

  tags = {
    Name = "${local.name}-b"
  }
}

resource "aws_default_security_group" "antipode_mq" {
  vpc_id      = aws_vpc.antipode_mq.id

  ingress {
    protocol          = "all"
    from_port         = 0
    to_port           = 0
    cidr_blocks       = ["0.0.0.0/0"] # Anywhere IPv4
    ipv6_cidr_blocks  = ["::/0"]      # Anywhere IPv6    
    self              = true
  }

  egress {
    protocol          = "all"
    from_port         = 0
    to_port           = 0
    cidr_blocks       = ["0.0.0.0/0"] # Anywhere IPv4
    ipv6_cidr_blocks  = ["::/0"]      # Anywhere IPv6    
    self              = true
  }

  tags = {
    Name = "${local.name}"
  }
}

resource "aws_internet_gateway" "antipode_mq" {
  # attach to vpc
  vpc_id = aws_vpc.antipode_mq.id

  tags = {
    Name = "${local.name}"
  }
}

resource "aws_default_route_table" "antipode_mq" {
  default_route_table_id  = aws_vpc.antipode_mq.default_route_table_id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.antipode_mq.id
  }

  tags = {
    Name = "${local.name}"
  }
}

# -------------------------------------------
# Security group for rendezvous ec2 instances
# -------------------------------------------

resource "aws_security_group" "rendezvous" {
  name        = "${local.name_rendezvous}"
  description = "Security group for rendezvous ssh and tcp connections"
  vpc_id      = aws_vpc.antipode_mq.id

  # connection to rendezvous server
  ingress {
    protocol          = "TCP"
    from_port         = local.vpc_config.rendezvous_port[data.aws_region.current.name]
    to_port           = local.vpc_config.rendezvous_port[data.aws_region.current.name]
    cidr_blocks       = ["0.0.0.0/0"] # Anywhere IPv4
    ipv6_cidr_blocks  = ["::/0"]              # Anywhere IPv6
  }

  # ssh connections to rendezvous machine
  ingress {
    protocol          = "TCP"
    from_port         = 22
    to_port           = 22
    cidr_blocks       = [local.vpc_config.ssh_cidr] 
  }

  ingress {  
    protocol          = "all"
    from_port         = 0
    to_port           = 0
    self              = true
  }

  egress {
    protocol          = "all"
    from_port         = 0
    to_port           = 0
    cidr_blocks       = ["0.0.0.0/0"] # Anywhere IPv4
    ipv6_cidr_blocks  = ["::/0"]      # Anywhere IPv6    
    self              = true
  }

  tags = {
    Name = "${local.name_rendezvous}"
  }
}