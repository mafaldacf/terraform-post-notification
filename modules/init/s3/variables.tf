variable "replication_rule" {
  description   = "Create s3 replication rule from writer to reader"
  default       = false
  type          = bool
}

variable "writer" {
  description   = "AWS writer region"
  default       = "eu-central-1"
  type          = string
}

variable "reader" {
  description   = "AWS writer region"
  default       = "us-east-1"
  type          = string
}