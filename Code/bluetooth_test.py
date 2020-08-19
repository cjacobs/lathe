#!/usr/bin/env python2

import os
import subprocess
import time

import bluetooth

def handle_connection(client_sock):
    try:
        client_sock.send('Hello')
        while True:
            response = client_sock.recv(1024)
            if response == '' :
                return
            print response
    except OSError:
        pass
    except bluetooth.btcommon.BluetoothError:
        pass

if __name__ == '__main__':
    try:
        while True:
            server_sock = bluetooth.BluetoothSocket(bluetooth.RFCOMM)
            server_sock.bind(('', bluetooth.PORT_ANY))
            server_sock.listen(1)
            port = server_sock.getsockname()[1]
            # uuid = "815425a5-bfac-47bf-9321-c5ff980b5e11"
            # bluetooth.advertise_service(server_sock, "RPi serial config",
            #                 service_id = uuid,
            #                 service_classes = [ uuid, SERIAL_PORT_CLASS ],
            #                 profiles = [ SERIAL_PORT_PROFILE ])
            print "Waiting for connection on RFCOMM channel %d" % port
            client_sock, address = server_sock.accept()
            print "Accepted connection from ", address
            
            handle_connection(client_sock)
            
            client_sock.close()
            server_sock.close()
            
            # finished
            print 'Finished\n'
    except (KeyboardInterrupt, SystemExit):
        print '\nExiting\n'
