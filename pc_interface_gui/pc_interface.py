
import numpy as np
import matplotlib.pyplot as pyplot
import time


def main():

    pyplot.ion()    

    pyplot.figure()
    pyplot.hold(True)
    pyplot.xlabel('Time (s)')
    pyplot.ylabel('Position')

    x = 0
    while 1:
    
        y = np.sin(2.0*3.14159*x)
        pyplot.hold(True)
        pyplot.plot(x,y,'r.')
        pyplot.axis([max(x-1,0), max(x,1) ,-1.5,1.5])
        pyplot.draw()
        time.sleep(.033)
        x+= 0.01
        


if __name__ == '__main__':
    main()
    