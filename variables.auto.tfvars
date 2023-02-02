project_name = "infra-global"

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
    username = "ceo@magicskunk.dev"
    email    = "fedjatomasev@yahoo.com"
    groups   = ["admin"]
  },
  {
    username = "dejano.dev@magicskunk.dev"
    email    = "dejano.with.tie@gmail.com"
    groups   = ["dev"]
  },
  {
    username = "dev@magicskunk.dev"
    email    = "dejano.with.tie@gmail.com"
    groups   = ["dev"]
  }
]

primary_domain = "karambol.dev"
