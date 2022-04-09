provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "comp-wolf" {
  ami="ami-0ed9277fb7eb570c9"
  instance_type="t2.micro"
  key_name="comp-wolf"
  aws_security_group = "${aws_secount_group.SG1.Id}"
}

resource "aws_security_group" "SG1" {
    ingress = [ {
      cidr_blocks = [ "0.0.0.0/0" ]
      from_port = 22
      protocol = "SSH"
      to_port = 22
    } ]
  
}