variable "common_tags" {
  description = "Required tags to provision resources"
  type        = map(string)
  default = {
    Owner           = "harels"
    bootcamp        = "19"
    expiration_date = "30-12-23"
    managed_by      = "Terraform"
  }
}

variable "instances" {
    default = ["instance1",  "instance5","instance4","instance2","instance3"]
}