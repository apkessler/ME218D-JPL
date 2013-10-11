import processing.serial.*;
import controlP5.*;

//Fonts...
PFont gillsf;
PFont monof;

/*********************CONSTANTS*****************************************/
final int NUM_SENSORS = 8;
final int SENSOR_MAX = 1024;
final int X_BASE = 50;
final int Y_BASE = 100;
final int X_SPACING = 100;
final int Y_SPACING = 0;

//Lists...
final String[] BAUD_LIST = {"2400", "4800", "9600", "19200", "38400","57600", "115200"};
final String[] DATA_BITS_LIST = {"6","7","8"};
final String[] PARITY_LIST = {"none", "even", "odd"};
final String[] STOP_LIST = {"1", "1.5", "2"};

final int Y_SERIAL = 500;
final int X_SERIAL = 70;
final int BUTTON_HEIGHT = 30;

//Colors...
final color DISCONNECTED_COLOR = color(40,200,6);
final color CONNECTED_COLOR = color(255,0,0);
 
/****************************GLOBALS**********************************/  
BarPlot[] sensorPlots = new BarPlot[NUM_SENSORS]; //sensor plots

String[] file; //file of sample data to display 
int dataIndex = 0;

//Serial Port variables
Serial thePort;
boolean portOpen = false;

//ControlP5 vars...
ControlP5 controlP5;
DropdownList ddl_ports, ddl_baud, ddl_dbits, ddl_parity, ddl_stop;
Button but1;
CheckBox checkbox;

/************************FUNCTIONS************************************/
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

  ddl_ports = controlP5.addDropdownList("Serial port", 90, Y_SERIAL, 200, 300);
  customizeDropdownList(ddl_ports, Serial.list());

  ddl_baud = controlP5.addDropdownList("Baud rate", 300, Y_SERIAL, 70, 300);
  customizeDropdownList(ddl_baud, BAUD_LIST);
  
  ddl_dbits = controlP5.addDropdownList("Data bits", 380, Y_SERIAL, 70, 300);
  customizeDropdownList(ddl_dbits, DATA_BITS_LIST);
  
  ddl_parity = controlP5.addDropdownList("Parity", 460, Y_SERIAL, 70, 300);
  customizeDropdownList(ddl_parity, PARITY_LIST);
  
  ddl_stop = controlP5.addDropdownList("Stop Bits", 540, Y_SERIAL, 70, 300);
  customizeDropdownList(ddl_stop, STOP_LIST);
  
  but1 = controlP5.addButton("connect", 0, 680, Y_SERIAL - BUTTON_HEIGHT + 5, 60, BUTTON_HEIGHT);
  but1.setColorBackground(color(255,0,0));
  
  checkbox = controlP5.addCheckBox("Flow control", 620, Y_SERIAL - 27);
  checkbox.addItem("CTR",0);
  checkbox.addItem("DTR", 0);
  checkbox.addItem("XON", 0);
  checkbox.setItemsPerRow(1);
}

/*
 * The draw() function is called at 30 FPS.
 */
void draw() 
{
  background(11, 95, 165);
 
 //Draw the title text...
  fill(0);
  textSize(15);
  textAlign(LEFT, CENTER);
  text("Force sensors...",30,50);
  
  textSize(15);
  textAlign(LEFT, CENTER);
  text("Serial settings...", X_SERIAL, Y_SERIAL - 50);
  
  if (portOpen)
  {
    text("Connected!", X_SERIAL + 200, Y_SERIAL - 50);
    but1.setColorBackground(CONNECTED_COLOR);
  }
  else
  {
   text("Not connected.", X_SERIAL + 200, Y_SERIAL - 50); 
   but1.setColorBackground(DISCONNECTED_COLOR);
  }
  
  //Draw the box around the serial stuff
  
  fill(0,0,0,30);
  stroke(0);
  rect(X_SERIAL, 465, 680, 50); 
  
  
  //Draw the box around the graphs
  fill(0,0,0,30);
  stroke(0);
  rect(30, 70, 800, 250); 
  
  //Draw all the bar graphs...
  for (int i = 0; i < NUM_SENSORS; i++)
  {sensorPlots[i].draw();}
  
   
  

  //Get the next entry from the data file...
 // float thisLevel = float(file[dataIndex]);
  /*
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
  */
 
 drawMouseCrosshair(); 
  
}


void customizeDropdownList(DropdownList ddl, String[] optList) 
{
  //ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(20);
  ddl.setBarHeight(20);
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

String ddlGetSelected(DropdownList ddl)
{
 return ddl.getItem(int(ddl.getValue())).getName();
}

public void connect(float theValue)
{
   println("Connect pushed."); 


  String portName = ddlGetSelected(ddl_ports);
  int baudVal = Integer.parseInt(ddlGetSelected(ddl_baud));
   println("Port: " + portName);
   println("Baud: " + baudVal);

   
   thePort = new Serial(this, portName, baudVal);
   thePort.bufferUntil('\n'); //trigger a SerialEvent every time a new line gets fed in
   portOpen = true;

   
  
}

void serialEvent(Serial _port) 
{ 
  String line = _port.readString();
  int[] nums = int(split(line, ' '));

  System.out.printf("[%d,%d,%d,%d,%d,%d,%d,%d]\n", nums[0], nums[1],nums[2],nums[3],nums[4],nums[5],nums[6],nums[7]);
  for (int i = 0; i < NUM_SENSORS; i++)
  {sensorPlots[i].setLevel(float(nums[i])/float(SENSOR_MAX));}
  
} 

void drawMouseCrosshair()
{
 
  fill(0);
  textSize(10);
  text("(" + mouseX +"," + mouseY +")",mouseX+2,mouseY); 
  line(mouseX, mouseY - 5, mouseX, mouseY + 5);
  line(mouseX- 5, mouseY, mouseX+5, mouseY);
  
}
