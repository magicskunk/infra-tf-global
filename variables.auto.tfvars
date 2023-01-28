project_name = "infra-global"

aws_account = "nonprod"

aws_region = {
  nonprod = "eu-central-1"
  prod    = "eu-central-1"
}

aws_region_us = {
  nonprod = "us-east-1"
  prod    = "us-east-1"
}

user = [
  {
    username = "dev"
    email    = "dejano.with.tie+magicskunk@gmail.com"
    groups   = ["dev"]
  },
  {
    username = "ceo"
    email    = "fedjatomasev+magicskunk@yahoo.com"
    groups   = ["admin"]
  }
]

primary_domain = "karambol.dev"
