variable "account" {
  default = "moc-prometheus-sandbox"
}

variable "region" {
  default = "us-west-2"
}

variable "environment" {
  default = "stage"
}

variable "service_name" {
  default = "federator"
}

variable "instance_type" {
  default = "t2.medium"
}

variable "technical_owner" {
  default = "infra-aws@mozilla.com"
}

variable "ami" {}
