project_name = "global"

aws_account = "nonprod"

aws_region = {
  nonprod = "eu-central-1"
  prod    = "eu-central-1"
}

user = [
  {
    username = "dejano-with-tie"
    email    = "dejanopocket+magicskunk@gmail.com"
    groups   = ["admin", "dev"]
  }
]
