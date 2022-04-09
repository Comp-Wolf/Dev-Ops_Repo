terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.8.0"
    }
  }
}

provider "aws" {
    region = "us-east-1" # Configuration options
}

locals {
  mytag = "comp-wolf-local"
}

resource "aws_instance" "tf-ec2" {
    ami = "ami-0c02fb55956c7d316"
    instance_type = "t2.micro"
    key_name = "comp-wolf"
    tags = {
        "Name" = "${local.mytag}"
    }
}

resource "aws_s3_bucket" "tf-s3" {
  bucket = "${var.s3_bucket_name}-${count.index}"
  count = var.num_of_buckets != 2 ? var.num_of_buckets : 3
}