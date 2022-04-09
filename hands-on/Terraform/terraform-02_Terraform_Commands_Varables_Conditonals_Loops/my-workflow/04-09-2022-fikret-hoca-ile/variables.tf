variable "ec2-type" {
  default = "t2.micro"
}

variable "ec2-name" {
  default = "comp-wolf"
}

variable "ec2-ami" {
  default = "ami-0c02fb55956c7d316"
}

variable "num_of_buckets" {
  default = 2
}

variable "s3_bucket_name" {
  default = "comp-wolf-new"
}
