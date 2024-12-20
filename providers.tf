# terraform {
#   ##Backend storage for tfstate
#   backend "remote" {
#     hostname     = "backend.api.env0.com"
#     organization = ""

#     workspaces {
#       name = "AWS-PLAYGROUND-ENV0-MODULES"
#     }
#   }
# }

provider "aws" {
  region     = "us-east-1"
}
