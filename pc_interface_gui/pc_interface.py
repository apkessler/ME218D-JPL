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

N = 10 #number of sensors
    
#Limits on sensor readings
Y_max = 255
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

        line = serialPort.readline() #read until we get a newline
        if (line):
            print line #print the line we got
            tokens = line.split(';')[0].split(',')
            try:
                assert(len(tokens) == 2)
        
                sensorIndex = int(tokens[0])
                sensorRead = int(tokens[1])
                
                assert(sensorIndex > 0 and sensorIndex < N)
                
            except ValueError:
                print "Bad serial input (%s)!" % line
                exit()
            except AssertionError:
                print "Bad serial input (%s)!" % line
                exit()
                
            y[sensorIndex] = sensorRead
            
            #Draw the latest plot
            drawBarGraph(x,y)
        

def setupSerial():
   
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
            return None
    except ValueError:
        print "Bad input."
        return None
        
    portName = list_ports.comports()[ser_index][0]
    print "Attempting to open %s..." % portName
    try:
        ser = serial.Serial(portName, 115200, timeout=0) #open the selected serial port
    except SerialExcepton as err:
        print "Error opening serial port: %s" % err
        return None
    
    print "Sucessfully opened the serial port!"

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





if __name__ == '__main__':
    main()
