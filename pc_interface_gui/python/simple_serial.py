#!/usr/bin/python

#Simple serial program using pySerial

from serial.tools import list_ports
import serial




def main():
    print "Available COM ports:"

    ii = 0
    numSerialPorts = len(list_ports.comports())
    for port in list_ports.comports():
        print "[%01d] %s" % (ii, port[0])
        ii = ii + 1
    

    
    userIn = raw_input("Which serial port? ")
    try:
        ser_index = int(userIn)
        if (ser_index >= numSerialPorts or ser_index < 0):
            print "Bad input."
            exit()
    except ValueError:
        print "Bad input."
        exit()
        
    portName = list_ports.comports()[ser_index][0]
    print "Attempting to open %s..." % portName
    try:
        ser = serial.Serial(portName, 115200, timeout=0) #open the selected serial port
    except SerialExcepton as err:
        print "Error opening serial port: %s" % err
        exit()
    
    print "Sucessfully opened the serial port!"


    print "Closing the serial port..."
    ser.close() #close the port
    print "Closed."
    
    
    
if __name__ == '__main__':
    main()