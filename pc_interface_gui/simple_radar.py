
import numpy as np
import matplotlib.pyplot as pyplot
import time


def main():

    pyplot.ion() #turn interactive mode on

    pyplot.figure()

    pyplot.xlabel('Position')
    pyplot.ylabel('Reading')

    x=[]
    y=[]
    for ii in range(0,100):
        x.append(ii)
        y.append(0)
            
    kk = 0 
    while 1:
        kk+=1

        jj = kk%100
        y[jj] = np.sin(2*kk/70.0*np.pi)
        
        pyplot.plot(np.array(x), np.array(y),'r.')
        pyplot.hold(True)
        pyplot.plot(np.array([x[jj], x[jj]]), np.array([-1, 1]),'ko-', lw=1)
        pyplot.axis([0,100, -1, 1])
        pyplot.grid()
        pyplot.hold(False)
        pyplot.draw()
        time.sleep(.033)



if __name__ == '__main__':
    main()
    