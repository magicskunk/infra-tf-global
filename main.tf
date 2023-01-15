provider "aws" {
  region = lookup(var.aws_region, var.aws_account)

  default_tags {
    tags = {
      Org         = var.organization_name
      Project     = var.project_name
      Environment = var.aws_account
      Terraform   = "true"
      Source      = "infra-tf-global"
    }
  }
}
