variable "deploy" {
  description   = "Deploy cache cluster"
  default       = true
  type          = bool
}

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