import processing.serial.*;
import controlP5.*;

//Fonts...
PFont gillsf;
PFont monof;

/**************************************CONSTANTS*****************************************/
final int WINDOW_W = 1200;
final int WINDOW_H = 500;


final int NUM_SENSORS = 224;
final int SENSOR_MAX = 1023;
final int X_BASE = 20;
final int Y_BASE = 140;
final int X_SPACING = 0;
final int Y_SPACING = 0;
final int NUM_COLS = 28;
final int NUM_ROWS = ceil(float(NUM_SENSORS)/float(NUM_COLS));
final int W_BOX = 40;
final int H_BOX = 40;
final int X_BOX_BASE = X_BASE + 2*X_SPACING + W_BOX;
final int Y_BOX_BASE = Y_BASE + Y_SPACING;

//Lists...
final String[] BAUD_LIST = {"115200", "57600", "38400", "19200", "9600", "4800", "2400"};
final String[] DATA_BITS_LIST = {"6","7","8"};
final String[] PARITY_LIST = {"none", "even", "odd"};
final String[] STOP_LIST = {"1", "1.5", "2"};

final int Y_SERIAL = 70;
final int X_SERIAL = 60;
final int BUTTON_HEIGHT = 30;

//Colors...
final color DISCONNECTED_COLOR = color(40,200,6);
final color CONNECTED_COLOR = color(255,0,0);
final color BG_COLOR = color(20,20,20);
final color BOX_BG_COLOR = color(11,95,165);
final color FONT_COLOR = color(255);
 
 
//Heat map...
final int NUM_COLORS = 1024;
color[] colorMap = new color[NUM_COLORS];
/***************************************GLOBALS******************************************/  

ColorPlot[] sensorPlots = new ColorPlot[NUM_SENSORS]; //sensor plots

//Serial Port variables
Serial thePort;
boolean portOpen = false;
int fade_start;

//ControlP5 vars...
ControlP5 controlP5;
DropdownList ddl_ports, ddl_baud, ddl_dbits, ddl_parity, ddl_stop;
Button but1;
CheckBox checkbox;

CheckBox plotOptions;

boolean mouseDebug = false;
boolean showOverlay = false;
boolean mouseCrosshair = false;

PShape nasa_logo;
PShape jpl_logo;
float aniScale = 1.0;
/****************************************FUNCTIONS***************************************/
/*
 * The setup() functions get everything ready to go - executed
 * once before draw() is ever called.
 */
void setup()
{
  size(WINDOW_W, WINDOW_H); // size(x,y) of the window in pixels, stored automatically in the parameters width and height
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
     x_coord = (ii%NUM_COLS)*(W_BOX + X_SPACING) + X_BOX_BASE;
     y_coord = (ii/NUM_COLS)*(H_BOX + Y_SPACING) + Y_BOX_BASE;
     sensorPlots[ii] = new ColorPlot(name_str, x_coord, y_coord, W_BOX, H_BOX, colorMap); 
     sensorPlots[ii].setShowLabel(false);
     sensorPlots[ii].setShowValue(false);
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
  
  plotOptions = controlP5.addCheckBox("Plot Options", X_BASE, Y_BASE - 30);
  plotOptions.addItem("Overlay",0);
  plotOptions.addItem("Test Color", 0);
  plotOptions.addItem("Crosshair", 0);
  plotOptions.setItemsPerRow(3);
  plotOptions.setSpacingColumn(50);

  
  loadColorMap();
 
  nasa_logo = loadShape("nasa.svg");
  jpl_logo = loadShape("jpl.svg");
 
  jpl_logo.scale(0.7);
}

/*
 * The draw() function is called at 30 FPS.
 */
void draw() 
{
  background(BG_COLOR);
    
  drawSerialSettings(); 
 

 
 
 if (mouseDebug)
 {
   for (int i = 0; i < NUM_SENSORS; i++)
   {
     sensorPlots[i].setLevel(float(mouseX)/width);
   }
 }
  drawColorPlots();
  
  drawLogos();
  
  if (mouseCrosshair)
  {
     drawMouseCrosshair(); 
  }
}

void drawLogos()
{
  
  shapeMode(CENTER);
  shape(nasa_logo, 1200, 130);
  shape(jpl_logo, 1000, 80);
  
  if (aniScale > 0.4)
  {
      nasa_logo.scale(0.96);
      aniScale *=0.96;
  }
 

  
  
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
   //thePort.bufferUntil('\n'); //trigger a SerialEvent every time a new line gets fed in
   thePort.buffer(18);
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
  try
  {  
    String line = _port.readString();
    if (line.length() < NUM_ROWS*2+1)
    {
      System.out.printf("Line 0x%02X too short: %d\n",(byte)line.charAt(0), (int)line.length());
      _port.bufferUntil('\n');
      return;
    }
    if (line.charAt(17) != '\n')
    {
      _port.bufferUntil('\n');
      return;
    }
    _port.buffer(18);
    
    int col = ((byte) line.charAt(0));
    
    System.out.printf("Got column %d (0x%X).\n",col,col);
    for (int ii = 0; ii < NUM_ROWS; ii++)
    { 
      int MSB = line.charAt(2*ii +1) % 256;
      int LSB = line.charAt(2*ii +2) % 256;
      int thisRead = MSB*256 + LSB;
      System.out.printf("%d: (0x%02X,0x%02X) = %d,%d = %d\n",ii,(byte)MSB,(byte)LSB,MSB,LSB,thisRead);
      if (thisRead <= 1023 && thisRead >= 0)
      {
         sensorPlots[28*ii+col].setLevel(1.0 - float(thisRead)/float(SENSOR_MAX));
      }
    }
    
  }
  catch (Exception e){
    println(e); 
  }
  
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


void drawColorPlots()
{

  //Draw the framing box
  fill(BOX_BG_COLOR);
  stroke(255);
  int frame_w = NUM_COLS * (W_BOX + X_SPACING) + 2*X_SPACING + W_BOX;
  int frame_h = NUM_ROWS * (H_BOX + Y_SPACING) + Y_SPACING;
  rect(X_BASE, Y_BASE, frame_w, frame_h); 
  
  //Draw all the bar graphs...
  for (int i = 0; i < NUM_SENSORS; i++)
  {sensorPlots[i].draw(showOverlay);}
  
  //Draw the graph text...
  fill(FONT_COLOR);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("Force Sensors",X_BASE + frame_w/2,Y_BASE - 15);
  

  
  //drawMapLegend()
  int LEG_X = X_BASE + X_SPACING;
  int LEG_Y = Y_BASE + Y_SPACING;
  int LEG_WIDTH = W_BOX;
  int COLOR_HEIGHT = 1;
  int LEG_HEIGHT = NUM_ROWS*H_BOX + (NUM_ROWS - 1)*Y_SPACING;
  int NUM_LEG_COLORS = min(LEG_HEIGHT/COLOR_HEIGHT,1024);
   
   noStroke();    
   fill(255);
   rect(LEG_X -1, LEG_Y - 1, LEG_WIDTH + 2, NUM_LEG_COLORS*COLOR_HEIGHT + 3);
  
    
    int ii;
    int cInd;
    for (ii = 0; ii < NUM_LEG_COLORS; ii++)
    {
        cInd = int(map(ii, 0, NUM_LEG_COLORS, 0, NUM_COLORS)); 
        fill(colorMap[cInd]);
        noStroke();
        rect(LEG_X, LEG_Y + (NUM_LEG_COLORS - ii)*COLOR_HEIGHT, LEG_WIDTH, COLOR_HEIGHT);
    }
   
    //Draw legend label 
    fill(FONT_COLOR);
    textSize(10);
    textAlign(CENTER, CENTER);
    text("Color Map", LEG_X + W_BOX/2, LEG_Y - 8);
  
 
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
    break;
   case 'm':
     mouseDebug = !mouseDebug; 
     plotOptions.toggle(1);
     break;
   
   default:
    println("No action defined for '" + c + "'.");
  }
   
}



void drawMapLegend()
{
    int LEG_X = 10;
    int LEG_Y = 100;
    int LEG_WIDTH = 50;
    int COLOR_HEIGHT = 1;
    int NUM_LEG_COLORS = 300;
    
    noStroke();    
    fill(255);
    rect(LEG_X -1, LEG_Y - 1, LEG_WIDTH + 2, NUM_LEG_COLORS*COLOR_HEIGHT + 3);
  
    
    int ii;
    int cInd;
    for (ii = 0; ii < NUM_LEG_COLORS; ii++)
    {
        cInd = int(map(ii, 0, NUM_LEG_COLORS, 0, NUM_COLORS)); 
        fill(colorMap[cInd]);
        noStroke();
        rect(LEG_X, LEG_Y + (NUM_LEG_COLORS - ii)*COLOR_HEIGHT, LEG_WIDTH, COLOR_HEIGHT);
    }
    
}

/* 
 * Load the color map from the text file.
 */
void loadColorMap()
{
   String lines[] = loadStrings("jet.txt");
   for (int i=0; i < lines.length; i++)
   {
      String[] rgb = split(lines[i],' ');
      colorMap[i] = color(Integer.parseInt(rgb[0]), Integer.parseInt(rgb[1]), Integer.parseInt(rgb[2]));
    } 
}



void controlEvent(ControlEvent theEvent) {
  if (theEvent.isFrom(plotOptions)) 
  {
    showOverlay = plotOptions.getState(0); 
    mouseDebug = plotOptions.getState(1);
    mouseCrosshair = plotOptions.getState(2);
  }
   
}
