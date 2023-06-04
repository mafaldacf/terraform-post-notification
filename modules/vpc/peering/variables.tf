variable "in_reader_region" {
  description   = "Executing module in reader region"
  default       = false
  type          = bool
}

variable "peering_region" {
  description   = "The AWS secondary region"
  type          = string
}