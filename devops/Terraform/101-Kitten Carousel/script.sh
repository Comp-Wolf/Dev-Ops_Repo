            #!/bin/bash 
            yum update -y
            yum install -y httpd
            cd /var/www/html
            FOLDER=" https://raw.githubusercontent.com/engingltekin/aws-devops-repository/main/AWS/Projects/Deploy-Static-Website-Using-CloudFormation/static-web"
            wget ${FOLDER}/index.html
            wget ${FOLDER}/cat0.jpg
            wget ${FOLDER}/cat1.jpg
            wget ${FOLDER}/cat2.jpg
            wget ${FOLDER}/cat3.png
            systemctl enable httpd
            systemctl start httpd