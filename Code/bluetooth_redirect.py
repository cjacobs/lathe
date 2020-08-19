#!/usr/bin/env python2
#
# redirect data from a bluetooth connection to a serial port and vice versa
#
# based on rfc2217 example by Chris Liechti <cliechti@gmx.net>

import argparse
import logging
import socket
import sys
import time
import threading
import serial

import bluetooth

class Redirector(object):
    def __init__(self, serial_instance, socket, debug=False):
        self.serial = serial_instance
        self.socket = socket
        self._write_lock = threading.Lock()
        self.log = logging.getLogger('redirector')

    def shortcircuit(self):
        """connect the serial port to the bluetooth port by copying everything
           from one side to the other"""
        self.alive = True
        self.thread_read = threading.Thread(target=self.reader)
        self.thread_read.daemon = True
        self.thread_read.name = 'serial->socket'
        self.thread_read.start()
        
        self.writer()

    def reader(self):
        """loop forever and copy serial->socket"""
        self.log.debug('reader thread started')
        while self.alive:
            try:
                data = self.serial.read(self.serial.in_waiting or 1)
                if data:
                    self.write(b''.join(data))
            except socket.error as msg:
                self.log.error('{}'.format(msg))
                # probably got disconnected
                break
        self.alive = False
        self.log.debug('reader thread terminated')

    def write(self, data):
        """thread safe socket write with no data escaping. used to send telnet stuff"""
        with self._write_lock:
            self.socket.sendall(data)

    def writer(self):
        """loop forever and copy socket->serial"""
        while self.alive:
            try:
                data = self.socket.recv(1024)
                if not data:
                    break
                self.serial.write(b''.join(data))
            except socket.error as msg:
                self.log.error('{}'.format(msg))
                # probably got disconnected
                break
        self.stop()

    def stop(self):
        """Stop copying"""
        self.log.debug('stopping')
        if self.alive:
            self.alive = False
            self.thread_read.join()


if __name__ == '__main__':

    parser = argparse.ArgumentParser(
        description="Serial to bluetooth redirector.")

    parser.add_argument('SERIALPORT')

    parser.add_argument(
        '-v', '--verbose',
        dest='verbosity',
        action='count',
        help='print more diagnostic messages (option can be given multiple times)',
        default=0)

    args = parser.parse_args()

    if args.verbosity > 3:
        args.verbosity = 3
    level = (logging.WARNING,
             logging.INFO,
             logging.DEBUG,
             logging.NOTSET)[args.verbosity]
    logging.basicConfig(level=logging.INFO)
    #~ logging.getLogger('root').setLevel(logging.INFO)
    logging.getLogger('btredirect').setLevel(level)

    # connect to serial port
    serial_port = serial.serial_for_url(args.SERIALPORT, do_not_open=True)
    serial_port.timeout = 3     # required so that the reader thread can exit
    # reset control line as no _remote_ "terminal" has been connected yet
    serial_port.dtr = False
    serial_port.rts = False

    logging.info("Bluetooth to Serial redirector - type Ctrl-C / BREAK to quit")

    try:
        serial_port.open()
    except serial.SerialException as e:
        logging.error("Could not open serial port {}: {}".format(serial_port.name, e))
        sys.exit(1)

    logging.info("Serving serial port: {}".format(serial_port.name))
    initial_settings = serial_port.get_settings()

    server_socket = bluetooth.BluetoothSocket(bluetooth.RFCOMM)
    server_socket.bind(('', bluetooth.PORT_ANY))
    server_socket.listen(1)
    port = server_socket.getsockname()[1]
    logging.info("Bluetooth port: {}".format(port))

    while True:
        try:
            client_socket, addr = server_socket.accept()
            logging.info('Accepted connection from {}:{}'.format(addr[0], addr[1]))

            serial_port.rts = True # ???
            serial_port.dtr = True # ???

            # enter bluetooth <-> serial loop
            r = Redirector(serial_port, client_socket, args.verbosity > 0)
            
            try:
                r.shortcircuit()
            finally:
                logging.info('Disconnected')
                r.stop()
                client_socket.close()
                serial_port.dtr = False
                serial_port.rts = False

                # Restore port settings
                serial_port.apply_settings(initial_settings)
        except KeyboardInterrupt:
            sys.stdout.write('\n')
            break
        except socket.error as msg:
            logging.error(str(msg))
    
    server_socket.close()
    logging.info('--- exit ---')
