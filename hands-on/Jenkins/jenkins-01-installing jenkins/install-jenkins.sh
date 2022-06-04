#! /bin/bash
yum update -y
amazon-linux-extras install java-openjdk11 -y
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
amazon-linux-extras install epel -y
yum install jenkins -y
systemctl start jenkins
systemctl enable jenkins
systemctl status jenkins
