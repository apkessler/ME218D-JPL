ME218D - JPL Wheel
==========

Code repository for Stanford ME218D, Fall 2013: JPL Tactile Wheel

Andrew Kessler, Riley Shear, David Choy

##Problem Statement
If you walk into a high-end running store, the sales person will likely to ask you to walk on a pad that reports how your weight is distributed across your foot as you take a step. Based on that information, they will reccomend a shoe model. As you walk around in your new shoes, your body relies on the nerves in your foot to provide information critical to maintaining balance and understanding the surface you are walking on. The same basic precepts should be true for Mars rovers as well. 

The advancement of wheeled mobility systems for planetary exploration faces two related problems in the designed of the wheels themselves. First, designers have diffictuly in generating test data that can be used to refine potential designs in terms of the wheels' interactions with a variety of substrates. Second, current wheels are effecitvely "numb", providing no immediate feedback to the system for control. As a potential mitigation of another "Free Spirit" event, JPL seeks the devleopment of tactile wheel technologies that will result in both more cabable wheels and more capable control of wheeled systems. 

## Repository Structure
###PC Interface GUI
Files in this folder are the PC end of the pressure sensor interface. The microcontroller sends data over a data channel (for now, UART), and the PC interface will interpret and plot this data in real time. The GUI is written in the Processing language, available for free at [http://processing.org](http://processing.org/ "Processing"). To run the GUI from source, you will also need the ControlP5 library, available [here](http://www.sojamo.de/libraries/controlP5/).

You will also need the FTDI drivers, found [here](http://www.ftdichip.com/Drivers/VCP.htm) in order to communicate with the UART device as a virtual COM port.

Precompiled executables for Windows, Mac OS X, and Linux (32-bit) are available in individual subdirectories.

###Microcontroller Code

This folder contains the source code for the program running on the PIC that is at the center of the wheel.
