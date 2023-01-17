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

variable "aws_region_us" {
  type        = map(string)
  description = "Map of {aws_account, aws_region_us}. Used for global services"
}

variable "user" {
  type = list(object({
    username = string
    groups   = list(string)
    email    = string
  }))
}
