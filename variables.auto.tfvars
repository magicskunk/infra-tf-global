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
    username = "ceo@magicskunk.dev"
    email    = "fedjatomasev@yahoo.com"
    groups   = ["admin"]
  },
  {
    username = "dejano@magicskunk.dev"
    email    = "dejano.with.tie@gmail.com"
    groups   = ["admin"]
  }
]

primary_domain = "karambol.dev"
