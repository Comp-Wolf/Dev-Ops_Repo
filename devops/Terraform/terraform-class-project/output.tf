output "ec2instance" {
  value = aws_instance.Kitten-Carousel[*].public_ip
  description = "Public IP Address"
}