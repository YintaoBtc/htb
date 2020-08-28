#!/usr/bin/python

import subprocess
import optparse
import re
import os

# Check MAC
def get_current_mac(interface):
    ifconfig = subprocess.check_output(['ifconfig', interface])
    mac_address = re.search(r'\w\w:\w\w:\w\w:\w\w:\w\w:\w\w', str(ifconfig))
 
    if mac_address:
        return mac_address.group(0)
 
    raise Exception('Sorry, MAC address not found')

# Menu shell
def get_arguments():
    parser = optparse.OptionParser()
 
    parser.add_option('-i', '--interface', dest='interface', help='Interface to change its MAC addr')
    parser.add_option('-m', '--mac', dest='new_mac', help='New MAC addr')
 
    (options, arguments) = parser.parse_args()
 
    if not options.interface:
        parser.error('[!] Please specify an interface, use --help for more info.')
    elif not options.new_mac:
        parser.error('[!] Please specify a MAC, use --help for more info.')
 
    return options

# Change MAC
def change_mac(interface, new_mac):
    print(f'Changing MAC address from {interface} to {new_mac}')
    subprocess.call(['ifconfig', interface, 'hw', 'ether', new_mac])


# Stop interface for set new MAC
def down_interface(interface):
    print(f'Turning off network interface: {interface}')
    subprocess.call(['ifconfig', interface, 'down'])


# Start interface with new settings
def up_interface(interface):
    print(f'Turning on network interface: {interface}')
    subprocess.call(['ifconfig', interface, 'up'])


# Main Function
if __name__ == "__main__":
    if os.geteuid() == 0:  # Check super user
        options = get_arguments()
        current_mac = get_current_mac(options.interface)
 
        down_interface(options.interface)
 
        print('Current MAC: {}'.format(current_mac))
        change_mac(options.interface, options.new_mac)
 
        up_interface(options.interface)
 
        if current_mac != options.new_mac:
            print('MAC address was succesfully changed to {}'.format(options.new_mac))
        else:
            raise Exception('It was not possible to change the MAC address')
    else:
        raise Exception('Pemission denied, need superuser for run this script')
