import processing.serial.*;
import controlP5.*;

//Fonts...
PFont gillsf;
PFont monof;

/**************************************CONSTANTS*****************************************/
final int NUM_SENSORS = 8;
final int SENSOR_MAX = 1024;
final int X_BASE = 50;
final int Y_BASE = 500;
final int X_SPACING = 100;
final int Y_SPACING = 0;

//Lists...
final String[] BAUD_LIST = {"2400", "4800", "9600", "19200", "38400","57600", "115200"};
final String[] DATA_BITS_LIST = {"6","7","8"};
final String[] PARITY_LIST = {"none", "even", "odd"};
final String[] STOP_LIST = {"1", "1.5", "2"};

final int Y_SERIAL = 70;
final int X_SERIAL = 30;
final int BUTTON_HEIGHT = 30;

//Colors...
final color DISCONNECTED_COLOR = color(40,200,6);
final color CONNECTED_COLOR = color(255,0,0);
final color BG_COLOR = color(20,20,20);
final color BOX_BG_COLOR = color(11,95,165);
final color FONT_COLOR = color(255);
 
/***************************************GLOBALS******************************************/  
BarPlot[] sensorPlots = new BarPlot[NUM_SENSORS]; //sensor plots


//Serial Port variables
Serial thePort;
boolean portOpen = false;
int fade_start;

//ControlP5 vars...
ControlP5 controlP5;
DropdownList ddl_ports, ddl_baud, ddl_dbits, ddl_parity, ddl_stop;
Button but1;
CheckBox checkbox;

/****************************************FUNCTIONS***************************************/
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
  background(BG_COLOR);

  String name_str;
  int x_coord;
  int y_coord;
  
  //Set up the positions of the bar graphs.
  for (int ii = 0; ii < NUM_SENSORS; ii++)
  {
     name_str = "S" + ii; 
     x_coord = X_BASE + ii*X_SPACING;
     y_coord = Y_BASE + ii*Y_SPACING;
     sensorPlots[ii] = new BarPlot(name_str, x_coord, y_coord); 
     sensorPlots[ii].setBackgroundColor(color(200,200,200));
  }
  
  //ControlP5 setup
  controlP5 = new ControlP5(this);

  ddl_ports = controlP5.addDropdownList("Serial port", X_SERIAL + 20, Y_SERIAL, 200, 300);
  customizeDropdownList(ddl_ports, Serial.list());

  ddl_baud = controlP5.addDropdownList("Baud rate", X_SERIAL +240, Y_SERIAL, 70, 300);
  customizeDropdownList(ddl_baud, BAUD_LIST);
  
  ddl_dbits = controlP5.addDropdownList("Data bits", X_SERIAL+ 320, Y_SERIAL, 70, 300);
  customizeDropdownList(ddl_dbits, DATA_BITS_LIST);
  
  ddl_parity = controlP5.addDropdownList("Parity", X_SERIAL+ 400, Y_SERIAL, 70, 300);
  customizeDropdownList(ddl_parity, PARITY_LIST);
  
  ddl_stop = controlP5.addDropdownList("Stop Bits", X_SERIAL+480, Y_SERIAL, 70, 300);
  customizeDropdownList(ddl_stop, STOP_LIST);
  
  but1 = controlP5.addButton("connect", 0, X_SERIAL+610, Y_SERIAL - BUTTON_HEIGHT + 5, 60, BUTTON_HEIGHT);
  but1.setColorBackground(color(255,0,0));
  
  checkbox = controlP5.addCheckBox("Flow control", X_SERIAL + 560, Y_SERIAL - 27);
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
  background(BG_COLOR);
   
  drawBarGraphs(); 
  drawSerialSettings(); 
 
 //drawMouseCrosshair(); 
  
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

/*
 * Callback for "Connect" button. 
 */ 
public void connect(float theValue)
{
   println("Connect pushed."); 
  
  if (!portOpen)
  {

  String portName = ddlGetSelected(ddl_ports);
  int baudVal = Integer.parseInt(ddlGetSelected(ddl_baud));
   println("Port: " + portName);
   println("Baud: " + baudVal);

   
   thePort = new Serial(this, portName, baudVal);
   thePort.bufferUntil('\n'); //trigger a SerialEvent every time a new line gets fed in
   portOpen = true;
   fade_start = millis();
  }
  else
  {
    portOpen = false;
    println("Closing serial port...");
    thePort.stop(); 
  }
   
  
}

/*
 * Function called whenever a newline is available on the serial port.
 */
void serialEvent(Serial _port) 
{ 
  String line = _port.readString();
  int[] nums = int(split(line, ' '));

  System.out.printf("[%d,%d,%d,%d,%d,%d,%d,%d]\n", nums[0], nums[1],nums[2],nums[3],nums[4],nums[5],nums[6],nums[7]);
  for (int i = 0; i < NUM_SENSORS; i++)
  {sensorPlots[i].setLevel(float(nums[i])/float(SENSOR_MAX));}
  
} 

/*
 * Draw a nice little crosshair over the pointer with coords so you can see where you are.
 */
void drawMouseCrosshair()
{
 
  fill(FONT_COLOR);
  textSize(10);
  text("(" + mouseX +"," + mouseY +")",mouseX+2,mouseY); 
  line(mouseX, mouseY - 5, mouseX, mouseY + 5);
  line(mouseX- 5, mouseY, mouseX+5, mouseY);
  
}

void drawCoverBox()
{
   if (portOpen)
   {
     int now = millis();
     float fade_length = 3000.0; //ms 
     int opacity_now = max(255 - floor(min((now - fade_start)/fade_length*255.0, 255)), 0);
     fill(BG_COLOR, opacity_now);
   }
   else
   {
     fill(BG_COLOR);
   }
     noStroke();
     rect(X_BASE - 11, Y_BASE - 31, 802, 262); 
}

void drawSerialSettings()
{
   //Draw framing box
  fill(BOX_BG_COLOR);
  stroke(255);
  rect(X_SERIAL, Y_SERIAL - 50, 680, 70); 
  
  textSize(12);
  textAlign(LEFT, CENTER);
  fill(FONT_COLOR);
  text("Serial Settings", X_SERIAL + 5, Y_SERIAL - 40);
  
  if (portOpen)
  {
    text("Connected!", X_SERIAL + 200, Y_SERIAL - 40);
    but1.setColorBackground(CONNECTED_COLOR);
  }
  else
  {
   text("Not connected.", X_SERIAL + 200, Y_SERIAL - 40); 
   but1.setColorBackground(DISCONNECTED_COLOR);
  } 
}

void drawBarGraphs()
{
  //Draw the framing box
  fill(BOX_BG_COLOR);
  stroke(255);
  rect(X_BASE - 10, Y_BASE - 30, 800, 260); 
  
  //Draw all the bar graphs...
  for (int i = 0; i < NUM_SENSORS; i++)
  {sensorPlots[i].draw();}
  
  //Draw the graph text...
  fill(FONT_COLOR);
  textSize(15);
  textAlign(LEFT, CENTER);
  text("Force sensors...",X_BASE,Y_BASE - 20);
  
  //This box fades away once serial port is opened, needs to be called last to be in front
  drawCoverBox();
 
}


void keyPressed() 
{
  int keyIndex = -1;
  char c = key;
  
  switch (c)
  {
   case 'q':
    if (portOpen)
    {
      println("Closing serial port...");
      thePort.stop();
    }
    exit();
   default:
    println("No action defined for '" + c + "'.");
  }
   
}
