provider "aws" {
  region = "us-east-1"
}

# provider "aws" {
#   region = lookup(var.awsprops, "region")
# }

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.8.0"

    }
  }
}