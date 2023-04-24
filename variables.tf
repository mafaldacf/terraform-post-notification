variable "credentials_path" {
  description   = "The AWS credentials path"
  sensitive     = true
  type          = string
}

variable "writer_region" {
  description   = "The AWS writer region"
  default       = "eu-central-1"
  type          = string
}

variable "reader_region" {
  description   = "The AWS reader region"
  default       = "us-east-1"
  type          = string
}

# --------------
# Main Resources
# --------------

variable "create_main_resources" {
  description   = "Whether or not to create main AWS resources: VPC configuration, S3 buckets (lambdas & posts), Dynamo tables, SNS topic, SQS queue"
  default       = false
  type          = bool
}

variable "create_main_resources_vpcs" {
  description   = "Whether or not to create vpcs in all regions"
  default       = true
  type          = bool
}

variable "create_main_resources_dynamo" {
  description   = "Whether or not to create a dynamo table"
  default       = true
  type          = bool
}

variable "create_main_resources_sns" {
  description   = "Whether or not to create a sns topic"
  default       = true
  type          = bool
}

variable "create_main_resources_sqs" {
  description   = "Whether or not to create a sqs queue"
  default       = true
  type          = bool
}

variable "create_main_resources_s3" {
  description   = "Whether or not to create s3 buckets"
  default       = true
  type          = bool
}

# --------------------
# Deployment Resources
# --------------------

variable "create_rendezvous_ec2_instances" {
  description   = "Whether or not to initialize an ec2 instance for rendezvous in writer and reader regions"
  default       = false
  type          = bool
}

variable "create_vpc_endpoints" {
  description   = "Whether or not to create new vpc endpoints in writer and reader regions"
  default       = false
  type          = bool
}

variable "endpoints_services_writer_region" {
  description   = "The service endpoints for the writer region"
  default       = ["dynamo", "sns"]
  type          = list(string)
}

variable "endpoints_services_reader_region" {
  description   = "The service endpoints for the reader region"
  default       = ["dynamo", "sqs"]
  type          = list(string)
}