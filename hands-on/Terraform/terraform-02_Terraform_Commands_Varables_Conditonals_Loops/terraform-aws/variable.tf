variable "ec2_name" {
  default = "comp-wolf-ec2"
}

variable "ec2_type" {
  default = "t2.micro"
}

variable "ec2_ami" {
  default = "ami-0742b4e673072066f"
}

variable "s3_bucket_name" {
#  default = "comp-wolf-s3-bucket-variable-addwhateveryouwant"
}

variable "num_of_buckets" {
  default = 2
}