import processing.serial.*;
import controlP5.*;

//Fonts...
PFont gillsf;
PFont monof;

//Constants
/**/
final int NUM_SENSORS = 8;
final int X_BASE = 50;
final int Y_BASE = 100;
final int X_SPACING = 100;
final int Y_SPACING = 0;
final String[] BAUD_LIST = {"2400", "4800", "9600", "19200", "38400","57600", "115200"};

//Set up the array of sensor plots
BarPlot[] sensorPlots = new BarPlot[NUM_SENSORS];

//The file of sample data to display.
String[] file; 

//The global counter.
int dataIndex = 0;


//Setup all the ControlP5 stuff...
ControlP5 controlP5;
DropdownList ddl_ports, ddl_baud;
Button but1;

/*
 * The setup() functions get everything ready to go - executed
 * once before draw() is ever called.
 */
void setup()
{
  size(1000, 800); // size(x,y) of the window in pixels, stored automatically in the parameters width and height
  frameRate(30); // call the draw() function at 30 frames per second to update the window
  smooth();

  fill(255);
  background(11, 95, 165);

  file = loadStrings("test.txt");
  
  String name_str;
  int x_coord;
  int y_coord;
  
  //Set up the positions of the bar graphs.
  for (int ii = 0; ii < NUM_SENSORS; ii++)
  {
     name_str = "S_" + ii; 
     x_coord = X_BASE + ii*X_SPACING;
     y_coord = Y_BASE + ii*Y_SPACING;
     sensorPlots[ii] = new BarPlot(name_str, x_coord, y_coord); 
  }
  
  //ControlP5 setup
  controlP5 = new ControlP5(this);
  ddl_ports = controlP5.addDropdownList("Serial port", 90, 500, 200, 300);
  customizeDropdownList(ddl_ports, Serial.list());

  ddl_baud = controlP5.addDropdownList("Baud rate", 320, 500, 70, 300);
  customizeDropdownList(ddl_baud, BAUD_LIST);
  
  but1 = controlP5.addButton("connect", 0, 690, 475, 50, 30);
  
}

/*
 * The draw() function is called at 30 FPS.
 */
void draw() 
{
  background(11, 95, 165);
 
 //Draw the title text...
  fill(0);
  textSize(30);
  text("Wheel Sensors",20,50);
  
  //Draw the box around the serial stuff
  fill(0,0,0,30);
  stroke(0);
  rect(70, 465, 680, 50); 
  
  //Draw the box around the graphs
  fill(0,0,0,30);
  stroke(0);
  rect(30, 70, 800, 250); 
  
  //Draw all the bar graphs...
  for (int i = 0; i < NUM_SENSORS; i++)
  {sensorPlots[i].draw();}
  
   

  //Get the next entry from the data file...
  float thisLevel = float(file[dataIndex]);
  
  if(thisLevel >= 0)
  {
    for (int i = 0; i < NUM_SENSORS; i++)
      {sensorPlots[i].setLevel(thisLevel);}
    
    dataIndex++;
  }
  else
  {
    dataIndex = 0;
  }
  
 
  
  
}


void customizeDropdownList(DropdownList ddl, String[] optList) 
{
  //ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(20);
  ddl.setBarHeight(15);
  //ddl.captionLabel().set("pulldown");
  ddl.captionLabel().style().marginTop = 3;
  ddl.captionLabel().style().marginLeft = 3;
  ddl.valueLabel().style().marginTop = 3;
 
  for(int i=0;i< optList.length ;i++) 
  {
    ddl.addItem(optList[i],i);
  }
  //ddl.setColorBackground(color(60));
  //ddl.setColorActive(color(255,128));
}

public void connect(float theValue)
{
   println("Connect pushed."); 
  
}
