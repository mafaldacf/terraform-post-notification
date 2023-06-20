variable "replication_rule" {
  description   = "Create s3 replication rule from writer to reader"
  default       = false
  type          = bool
}

variable "region" {
  description   = "AWS current region"
  type          = string
}

variable "secondary_region" {
  description   = "AWS writer region"
  type          = string
  default       = "us-east-1"
}