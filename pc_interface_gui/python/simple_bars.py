
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
    for ii in range(0,10):
        x.append(ii)
        y.append(0)
            
    kk = 0 
    while 1:
        kk+=1

        jj = kk%10
        y[jj] = np.sin(2*kk/700.0*np.pi)
        
        pyplot.bar(np.array(x), np.array(y), width=0.8,align = 'center')
        pyplot.hold(True)
        pyplot.axis([-1, 11, -1, 1])
        pyplot.grid()
        pyplot.hold(False)
        pyplot.draw()
        time.sleep(.033)



if __name__ == '__main__':
    main()
    