variable "organization_name" {
  type    = string
  default = "magicskunk"
}

variable "project_name" {
  type = string
}

variable "aws_account" {
  type = string
}

variable "aws_region" {
  type        = map(string)
  description = "Map of {aws_account, aws_region}"
}
