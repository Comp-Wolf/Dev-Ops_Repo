# Kubernetes Phonebook Project Guide

# Outline

# Setting up Kubernetes Cluster
# Setup Docker files
# Pushed to Docker hub repository
# Secret and Config Volumes
# Services
 # SQL Deployment file
# Web Deployments
# Create Kubernetes Cluster

# Part 1 - Setting up the Kubernetes Cluster

Launch a Kubernetes Cluster of Ubuntu 20.04 with two nodes (one master, one worker) using the Cloudformation Template to Create Kubernetes Cluster. Note: Once the master node is up and running, the worker node automatically joins the cluster.

Check if Kubernetes is running and nodes are ready.

kubectl cluster-info
kubectl get node

# Part 2 - Setup Docker files

Create two docker files for both Search and Web

FROM python:flask
COPY . /app
WORKDIR /app
RUN pip install –r requirements.txt
EXPOSE 80
CMD python ./app.py
---

# Part 3 - Pushed to Docker Hub Repository

Open the terminal in each folder where your project files and docker file are located

sudo usermod -a -G docker ubuntu
sudo newgrp docker

sudo docker build -t "compwolf/phonebook_resultserver:1.0" .

sudo docker login
docker push compwolf/phonebook_resultserver:1.0
docker image ls

sudo docker build -t "compwolf/phonebook_webserver:1.0" .
docker push compwolf/phonebook_webserver:1.0

# Part 4 - Secret and ConfigMap Volumes
mkdir configuration_files & cd configuration_files

touch configmap.yaml

# touch configmap.yaml

Encode password

Echo –n ‘password’ | base64

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-configmap
data:
  mysql-database: phonebook #
  mysql-host: mysql-service
---

touch secret.yaml

# touch secret.yaml
---
apiVersion: v1
kind: Secret
metadata:
  name:  mysql-secret
data:
  mysql-root-password: Y29tcC13b2xm     # echo -n 'comp-wolf' | base64 (bu komut ile şifremizi base64 formatında veriyor)
  mysql-password: Y29tcC13b2xm
  mysql-username: Y2xhcnVzd2F5    # echo -n 'admin' | base64 (bu komut ile username mimizi base64 formatında veriyor)
type: Opaque

# Part 5 - Persistent Volumes

cd ..
mkdir solution_files & cd solution_files

touch db-pv.yaml

# touch db-pv.yaml
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: db-pv-vol
  labels:
    type: local #remote
spec:
  storageClassName: manual
  capacity:
    storage: 8Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/home/ubuntu/mnt/data"
---

touch db-pvc.yaml

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: database-persistent-volume-claim
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: manual
  resources:
    requests:
      storage: 5Gi
---

# Part 6 - DB deployment and Service

touch db-deployment.yaml

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name:  mysql-deployment
  labels:
    app:  mysql
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name:  mysql
        image:  mysql:5.7
        ports:
        - containerPort: 3306
        env:
        - name:  MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: mysql-root-password
        - name:  MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: mysql-password
        - name: MYSQL_USER
          valueFrom:
            configMapKeyRef:
              name: mysql-secret
              key: mysql-username
        - name: MYSQL_DATABASE
          valueFrom:
            configMapKeyRef:
              name: mysql-configmap
              key: mysql-database
        volumeMounts:
          - name: mysql-storage
            mountPath: /var/lib/mysql
      volumes:
        - name: mysql-storage
          persistentVolumeClaim:
            claimName: database-persistent-volume-claim
---

# Part 7 - db service

touch db-service.yaml

---
kind: Service
apiVersion: v1
metadata:
  name: mysql-service
spec:
  selector:
    app: mysql
  ports:
  - protocol: TCP
    port:  3306
    targetPort:  3306
---

# Part 8 - Web Deployment and Service

touch web-deployment.yaml

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
  labels:
    name: web-search
    app: phonebook-web
spec:
  replicas: 3
  selector:
    matchLabels:
      name: web-search
      app: phonebook-web
  template:
    metadata:
      labels:
        name: web-search
        app: phonebook-web
    spec:
      containers:
        - image: compwolf/phonebook_resultserver:1.0
          imagePullPolicy: Always
          name: myweb
          ports:
            - containerPort: 80
          env:
            - name: MYSQL_DATABASE_HOST
              valueFrom:
                configMapKeyRef:
                  name: mysql-configmap
                  key: mysql-host
            - name: MYSQL_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-secret
                  key: mysql-password
            - name: MYSQL_DATABASE
              valueFrom:
                configMapKeyRef:
                  name: mysql-configmap
                  key: mysql-database
            - name: MYSQL_USER
              valueFrom:
                configMapKeyRef:
                  name: mysql-secret
                  key: mysql-username
          resources:
            limits:
              memory: 500Mi
              cpu: 100m
            requests:
              memory: 250Mi
              cpu: 80m	
---

# Part 9 - Web Service

touch web-service.yaml

---
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  selector:
    app: phonebook-web
  type: NodePort
  ports:
    - protocol: TCP
      nodePort: 30002
      port: 80
      targetPort: 80
---

# Part 10 - Crud Deployment and Service

touch crud-deployment.yaml

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: crud-deployment
  labels:
    name: crud-ops
    app: phonebook-crud
spec:
  replicas: 3
  selector:
    matchLabels:
      name: crud-ops
      app: phonebook-crud
  template:
    metadata:
      labels:
        name: crud-ops
        app: phonebook-crud
    spec:
      containers:
        - image: compwolf/phonebook_webserver:1.0
          imagePullPolicy: Always
          name: myweb
          ports:
            - containerPort: 80
          env:
            - name: MYSQL_DATABASE_HOST
              valueFrom:
                configMapKeyRef:
                  name: mysql-configmap
                  key: mysql-host
            - name: MYSQL_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-secret
                  key: mysql-password
            - name: MYSQL_DATABASE
              valueFrom:
                configMapKeyRef:
                  name: mysql-configmap
                  key: mysql-database
            - name: MYSQL_USER
              valueFrom:
                configMapKeyRef:
                  name: mysql-secret
                  key: mysql-username
          resources:
            limits:
              memory: 500Mi
              cpu: 100m
            requests:
              memory: 250Mi
              cpu: 80m
--- 

# Part 11 - Crud Service

touch crud-service.yaml

---
apiVersion: v1
kind: Service
metadata:
  name: crud-service
spec:
  selector:
    app: phonebook-crud
  type: NodePort
  ports:
    - protocol: TCP
      nodePort: 30001
      port: 80
      targetPort: 80
---

# Part 11

cd ..

kubectl apply -f configuration_files/

kubectl apply -f solution_files/

