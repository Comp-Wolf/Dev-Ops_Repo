# Docker sık kullanılan komutlar

- Local de bulunan mevcut image’leri listeleler.
docker images 
Veya
docker image ls
- Çalışan container’ları listeler.
docker ps
Veya
docker container ls
- Çalışan ve çalışmayan tüm container’ları listeler.
docker ps -a
Veya
docker container ls -a
- Tüm container’ların Id’lerini listeler.
docker ps -aq
Veya
docker container ls -aq
- Uzak sunucudaki ( docker hub, gitlab container registry vb. ) registry den belirtilen image’i indirir.
Şablon:
docker pull <repository_name>/<image_name>:<image_tag>
Kullanım:
docker pull nginx
- //yukarıdaki kullanımla aynı tag yazılmaz ise latest baz alınır.
docker pull nginx:latest

docker pull nginx:stable

docker pull erenekincii/helloworld:1.1.100
- İlgili container’ı duraklatır
docker container pause [containerId]
- // docker container Id veya docker container adı verilebilir.
- Duraklatılmış container’ı çalışır hale getirir.
docker container unpause [containerId]
- // docker container Id veya docker container adı verilebilir.
- İlgili container’ı durdurur.
docker container stop [containerId]
- Duraklatılmış container’ı çalışır hale getirir.
docker container start [containerId]
- Container’ı siler.
- Durumu running olan container silinirken hata verecektir. Stop edip silinebilir.
docker container rm [containerId]
- Stop edilmeden silmek için -f parametresi kullanılabilir.
docker container rm [containerId] -f
- Container’a bağlı volume’leri silmek için -v parametresi kullanılabilir.
docker container rm [containerId] -f -v
- İlgili Image’i siler.
docker image rm [imageId veya image name]
- Docker deamon ile ilgili özet bilgileri döner.
docker info
- İlgili container’la ilgili detaylı bilgileri verir.
docker container inspect [containerId]
- Aynı şekilde, image ,network, volume de incelenebilmektedir.
- Tüm container’lar silinir
docker container rm $(docker ps -aq)
- // -f parametresi verilirse çalışan containerlarda silinmeye zorlanır.
- Çalışan tüm container’lar durdurulur.
docker container stop $(docker ps -aq)
- Tüm image’ler silinir.
docker image rm $(docker images -aq)
- Container tarafından kullanılmayan ve taglenmemiş image’leri siler.
docker image rm $(docker images -q -f dangling=true)
- Container log’larını listeler.
docker container logs [containerId]
- // f parametresi kullanılırsa loglar anlık olarak terminalde izlenir.
docker container logs -f [containerId]
- Çalışan bir container içerisine bağlanıp bash komutları çalıştırmak için kullanılır.
docker exec -it [containerId] /bin/bash
- Yeni bir container oluşturulur ve içerisine bağlanır.
- Python image’i kullanılarak proje1 adında bir container oluşmaktadır.
docker container run  -it --name proje1 python
- rm parametresi kullanılırsa container oluşur içerisine bağlanır ve containerdan çıkış yapıldıktan sonra container silinir.
docker container run --rm -it --name proje1 python
- Mevcutdaki bir containerdan image oluşturma.
docker container commit c_portainer erenekincii/portainer
- Bütün konteyların (listesini çıkart) ve stop et. Daha sonra ne kadar konteynır varsa (listele) sil.
docker stop $(docker ps -a) && docker rm -fv $(docker ps -a)
- Bütün konteynır imajlarının (listesini çıkart) ve zorla sil.
docker image rm --force $(docker image ls)
- image leri listeler
docker images
- ubuntu image ini siler
docker rmi ubuntu
- tüm containerları ini siler
docker container prune
- tüm volume leri ini siler
docker volume prune
- çalış mayan container ları listeler
docker ps -a // docker container ls -a
- çalışan container ları listeler
docker ps // docker container ls
- container çalıştır ve bağlan
docker start [containerId] && docker attach [containerId]