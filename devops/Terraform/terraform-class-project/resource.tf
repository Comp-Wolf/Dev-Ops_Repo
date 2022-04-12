data "aws_vpc" "main_vpc" {
  id = "vpc-065740f91024a5ae2"
}

module "web_server_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "web-server"
  description = "Security group for web-server with HTTP ports open within VPC"
  vpc_id      = data.aws_vpc.main_vpc.id

  ingress_cidr_blocks = [data.aws_vpc.main_vpc.cidr_block]
}

resource "aws_security_group" "ec2-instance-SG" {
  name        = "Ec2-SG"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.main_vpc.id
  // To Allow SSH Transport
  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  // To Allow Port 80 Transport
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "Kitten-Carousel" {
  for_each = {
    value1 = "DEV"
    value2 = "PROD" 
  }
  ami           = lookup(var.awsprops, "ami")
  instance_type = lookup(var.awsprops, "itype")
  #subnet_id = lookup(var.awsprops, "subnet") #FFXsubnet2
  associate_public_ip_address = lookup(var.awsprops, "publicip")
  key_name                    = lookup(var.awsprops, "keyname")
  user_data = file("./post_configuration.sh")  
  vpc_security_group_ids = [
    aws_security_group.ec2-instance-SG.id
  ]
  tags = {
    "Name" = each.value == "DEV" ?  "Still developing" : "ready to launch"
    #Name = "DEV"
  }
  depends_on = [
    aws_security_group.ec2-instance-SG
  ]

#   provisioner "local-exec" {
#     command = "echo http://${self.public_ip} > public_ip.txt"

#   }

#   provisioner "local-exec" {
#     command = "scp -i ~/.ssh/Engin_Linux.pem ec2-user@${self.public_ip}:/home/ec2-user"

#   }

#   connection {
#     host        = self.public_ip
#     type        = "ssh"
#     user        = "ec2-user"
#     private_key = file(pathexpand("~/Downloads/Engin_Linux.pem"))
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo yum update -y",
#       "sudo yum install httpd -y",
#       "sudo yum install git -y",
#       "cd /var/www/html",
#       "sudo git clone https://github.com/engingltekin/aws-devops-repository/tree/main/AWS/Projects/Deploy-Static-Website-Using-CloudFormation/static-web",
#       "sudo systemctl enable httpd",
#       "sudo systemctl start httpd"
#     ]
#   }

#   provisioner "file" {
#     content     = self.public_ip
#     destination = "/home/ec2-user/my_public_ip.txt"
#   }
}
