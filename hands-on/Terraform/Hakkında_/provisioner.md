PROVISIONER


1. local-exec

```go
provisioner "local-exec" {
 command = "echo httpd://${self.public_ip} > test_ip.txt"
}
```

bu komut baglanilan bilgisayarin ipsini local bilgisayara yazdirir.

2. file

```go
provisioner "file" {
        content = self.public_ip
        destination = "/home/ec2-user/nick_public_ip.txt"
```

bu komut baglanilan bilgisayarin ipsini baglanilan bilgisayara yazdirir


3.remote-exec

```go 
connection {
  host = self.public_ip
  type = "ssh"
  user = "ec2-user"
  private_key = file("~/firstkey.pem")
}

provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum -y install httpd",
      "sudo systemctl enable httpd",
      "sudo systemctl start httpd"
    ]
}

bu komut connection kismindaki bilgileri kullanarak karsi bilgisayara baglanarak inline komutlarini yukler. 


