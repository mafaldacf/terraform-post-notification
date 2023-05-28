variable "credentials_path" {
  description   = "The AWS credentials path"
  sensitive     = true
  type          = string
}

variable "writer" {
  description   = "The AWS writer region"
  default       = "eu-central-1"
  type          = string
}

variable "reader" {
  description   = "The AWS reader region"
  default       = "us-east-1"
  type          = string
}

# ----------
# Usage Type
# ----------

variable "init" {
  description   = "Initialize primary AWS resources"
  type          = bool
}

variable "deploy" {
  description   = "Deploy AWS resources for current application"
  type          = bool
}

# -------
# Storage
# -------

variable "post_storage" {
  description   = "Storage for posts"
  type          = bool
}

variable "notification_storage" {
  description   = "Storage for notifications"
  type          = string
}

# ------
# Extras
# ------

variable "rendezvous" {
  description   = "Initialize an ec2 instance for rendezvous in writer and reader regions"
  default       = false
  type          = bool
}