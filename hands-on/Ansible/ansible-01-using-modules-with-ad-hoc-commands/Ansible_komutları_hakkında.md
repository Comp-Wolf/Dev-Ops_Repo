--> $ ansible all -m ping
<<komutu, ansible ile bütün envanterimizdeki makinelere ping modülünü çalıştır diyoruz.>>

--> $ ansible node1 -m ping
<<komutu, node1 elaslı hosta git ve orada ping modülünü çalıştır.>>

--> $ ansible webservers --list-hosts
<<envanterimde grup ismi webservers yani host adresleri webservers olanları listele>>

--> komutumuzun sonuna "-o" yazdığımız zaman tek bir satırda gösterir. yoksa farklı farklı satırlarda gösterir.

--> $ ansible comp-wolf -m shell -a "systemctl status sshd"
<<sshd servisinin son statüs bilgilerine ulaşmak için, bağlanmak ile alakalı yapılanlar yani geçmişini gösteriyor>>

-->$ ansible comp-wolf -m command -a 'df -h'
<<listelenen default storujları gösterir>>

-->$ ansible comp-wolf webservers -a 'lsblk'
<<listelenen blok storujları gösterir>>

--->

-->

--->

-->

-->

-->

-->
