project_name = "global"

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
    username = "dejano.with.tie.dev"
    email    = "dejano.with.tie+magicskunk@gmail.com"
    groups   = ["dev"]
  }
]

primary_domain = "karambol.dev"
