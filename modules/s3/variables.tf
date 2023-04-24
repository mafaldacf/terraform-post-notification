variable "create_s3_replication" {
  description   = "Whether or not to create s3 replication from writer to reader"
  default       = false
  type          = bool
}

variable "writer_region" {
  description   = "AWS writer region"
  default       = "eu-central-1"
  type          = string
}

variable "reader_region" {
  description   = "AWS writer region"
  default       = "us-east-1"
  type          = string
}