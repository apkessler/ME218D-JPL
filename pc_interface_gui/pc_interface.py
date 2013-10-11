#!/usr/bin/python

# This program will update a bar graph of sensor reading in real-time as sensor data is 
# received over the serial port. Data input should be in form "x,y;\n" where "x" is the 
# sensor index, and "y" is the sensor reading.


#Using pySerial API
from serial.tools import list_ports
import serial

#Using Matplotlib API
import numpy as np
import matplotlib.pyplot as pyplot

import time
import os

N = 8 #number of sensors
BAUD_RATE = 115200

#Limits on sensor readings
Y_max = 1024
Y_min = 0
    


def main():

    serialPort = setupSerial()
    
    if (serialPort == None):
        exit()

    pyplot.ion() #turn interactive mode on
    pyplot.figure() #create a figure

    x=[]
    y=[]
    for ii in range(0,10):
        x.append(ii)
        y.append(0)
            
    drawBarGraph(x,y)       
 
    while 1:

        line = serialPort.readline() #read until we get a newline,
        if (line):
            tokens = line.split(';')[0].split(',')
            try:
                assert(len(tokens) == 2)
        
                sensorIndex = int(tokens[0])
                sensorRead = int(tokens[1])
                print "Reading on sensor %s = %s.\n" % (sensorIndex, sensorRead)
                assert(sensorIndex > 0 and sensorIndex < N)
                
            except ValueError:
                print "Bad serial input (%s)!" % line   
            except AssertionError:
                print "Bad serial input (%s)!" % line               
            else:
                y[sensorIndex] = sensorRead
                drawBarGraph(x,y) #redraw 

        

def setupSerial():
   
    print "Available COM ports:"
   
    ii = 0
    availablePorts = list_serial_ports()
    numSerialPorts = len(availablePorts)
    
    for port in availablePorts:
        print "[%01d] %s" % (ii, port)
        ii = ii + 1
    

    userIn = raw_input("Which serial port? ")
    try:
        ser_index = int(userIn)
        if (ser_index >= numSerialPorts or ser_index < 0):
            print "Bad input."
            return None
    except ValueError:
        print "Bad input."
        return None
        
    portName = availablePorts[ser_index]
    print "Attempting to open %s..." % portName
    try:
        ser = serial.Serial(portName,  baudrate=BAUD_RATE, bytesize=8, parity='N', stopbits=1, timeout=None, xonxoff=0, rtscts=0)
    except SerialExcepton as err:
        print "Error opening serial port: %s" % err
        return None
    
    print "Successfully opened the serial port!"

    return ser
    
def drawBarGraph(x,y):
    pyplot.bar(np.array(x), np.array(y), width=0.8,align = 'center')
    pyplot.hold(True)
    pyplot.axis([-1, N+1, Y_min, Y_max])       
    pyplot.grid()
    pyplot.xlabel('Position')
    pyplot.ylabel('Reading')
    pyplot.hold(False)
    pyplot.draw()

def list_serial_ports():
    # Windows
    if os.name == 'nt':
        # Scan for available ports.
        available = []
        for i in range(256):
            try:
                s = serial.Serial(i)
                available.append('COM'+str(i + 1))
                s.close()
            except serial.SerialException:
                pass
        return available
    else:
        # Mac / Linux
        return [port[0] for port in list_ports.comports()]



if __name__ == '__main__':
    main()
