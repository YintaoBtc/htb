# Mirai

IP: 10.10.10.48

## Ping
`ping -c 1 10.10.10.48`     
PING 10.10.10.48 (10.10.10.48) 56(84) bytes of data.
64 bytes from 10.10.10.48: icmp_seq=1 ttl=63 time=195 ms

--- 10.10.10.48 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 195.026/195.026/195.026/0.000 ms

## whichSystem.py
`whichSystem.py 10.10.10.48`

10.10.10.48 --> Linux

## Scanning
~~~
nmap -p- --open -T5 -v -n 10.10.10.48 -oN allPorts
nmap -sC -sV -p22,80,53 10.10.10.48 -oN targetedPorts
cat targetedPorts| grep http | grep -oP '\d{1,5}/tcp'
~~~

Entramos en las webs:

1. 10.10.10.48
2. 10.10.10.48:32400 --> Plex --> probamos logins

`nano /etc/hosts` --> Añadimos: 10.10.10.48    mirai.htb

En el navegador buscamos --> mirai.htb --> vemos que es una PI

Buscamos raspberry default password
- default user: pi
- default password: raspberry

~~~
cd Desktop/
cat user.txt
cd /root
id
sudo su
whoami
cd /root
cat root.txt
~~~

`df -h` --> vemos las particiones --> media/usbstick
~~~
cd /media/usbstick
ls
cat damnit.txt
~~~

`strings /dev/sdb`






