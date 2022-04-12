terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.9.0"
    }
  }
}

provider "aws" {
  # Configuration options
}

module "s3-website" {
  source = "../../modules/s3-website"

  bucket_name = "clarusway-s3-website"
}

output "website_endpoint" {
  value = module.s3-website.website_endpoint
}

