variable "vpc_id" {
  description = "ID of the VPC where to create security group"
  type        = string
}

variable "awsprops" {
  type = map(string)
  default = {
    region       = "us-east-1"
    vpc          = "vpc-5234832d"
    ami          = "ami-0c02fb55956c7d316"
    itype        = "t2.micro"
    subnet       = "subnet-81896c8e"
    publicip     = true
    keyname      = "Engin_Linux"
    secgroupname = "IAC-Sec-Group"
  }
}