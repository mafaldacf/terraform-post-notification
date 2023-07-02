variable "credentials_path" {
  description   = "The AWS credentials path"
  sensitive     = true
  type          = string
}

variable "writer" {
  description   = "The AWS writer region"
  default       = "eu-central-1"
  type          = string
  validation {
    condition     = contains(["eu-central-1", "us-east-1", "ap-southeast-1"], var.writer)
    error_message = "Invalid writer region. Possible values: eu-central-1, us-east-1, ap-southeast-1"
  }
}

variable "reader" {
  description   = "The AWS reader region"
  default       = "us-east-1"
  type          = string
  validation {
    condition     = contains(["eu-central-1", "us-east-1", "ap-southeast-1"], var.reader)
    error_message = "Invalid reader region. Possible values: eu-central-1, us-east-1, ap-southeast-1"
  } 
}

# ----------
# Usage Type
# ----------

variable "type" {
  description   = "Initialize primary AWS resources"
  type          = string
  validation {
    condition     = contains(["init", "deploy"], var.type)
    error_message = "Invalid type. Possible values: init, deploy"
  } 
}

# ------------------------------
# Deploy: Storage and Rendezvous
# ------------------------------

variable "post_storage" {
  description   = "Storage for posts"
  type          = string
  validation {
    condition     = contains(["dynamo", "s3", "cache", "mysql"], var.post_storage)
    error_message = "Invalid value for post_storage. Possible values: dynamo, s3, cache, mysql"
  } 
}

variable "notification_storage" {
  description   = "Storage for notifications"
  type          = string
  validation {
    condition     = contains(["sns", "mq"], var.notification_storage)
    error_message = "Invalid value for notification_storage. Possible values: dynamo, s3, cache, mysql"
  } 
}

variable "rendezvous" {
  description   = "Initialize an EC2 instance for rendezvous in writer and reader regions"
  type          = bool
}