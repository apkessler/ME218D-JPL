import processing.serial.*;
import controlP5.*;


/**************************************CONSTANTS*****************************************/
final int WINDOW_W = 1200;
final int WINDOW_H = 700;

final int Y_SERIAL = 70;
final int X_SERIAL = 20;
final int BUTTON_HEIGHT = 30;

//Colors...
final color DISCONNECTED_COLOR = color(40, 200, 6);
final color CONNECTED_COLOR = color(255, 0, 0);
final color BG_COLOR = color(20, 20, 20);
final color BOX_BG_COLOR = color(11, 95, 165);
final color FONT_COLOR = color(255);

final int X_BASE = 20;
final int Y_BASE = 140;
final int NUM_SENSORS = 224;
final int NUM_COLS = 28;
final int SENSOR_MAX = 1023;

//Default serial settings
final String DEFAULT_PORT = "COM27";
final int DEFAULT_BAUD = 115200;
/***************************************GLOBALS******************************************/

//Serial Port variables
Serial thePort;
boolean portOpen = false;

//ControlP5 vars...
ControlP5 controlP5;
DropdownList ddl_ports; 
Button but1, but2, log_but;
CheckBox checkbox;

CheckBox plotOptions;

boolean mouseDebug = false;
boolean showOverlay = false;
boolean mouseCrosshair = false;

PShape nasa_logo;
PShape jpl_logo;
float aniScale = 1.0;

HeatMap heatMap;
PrintWriter logger;
boolean logging = false;

LinePlot normPlot;

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

  heatMap = new HeatMap(X_BASE, Y_BASE, NUM_SENSORS, NUM_COLS);
  heatMap.loadColorMap();

  //ControlP5 setup
  controlP5 = new ControlP5(this);

  ddl_ports = controlP5.addDropdownList("Serial port", X_SERIAL + 20, Y_SERIAL, 200, 300);
  customizeDropdownList(ddl_ports, Serial.list());

  but1 = controlP5.addButton("connect", 0, X_SERIAL+250, Y_SERIAL - BUTTON_HEIGHT + 5, 80, BUTTON_HEIGHT);
  but1.setColorBackground(color(255, 0, 0));
  
  log_but = controlP5.addButton("log_button", 0, X_BASE+200, Y_BASE - BUTTON_HEIGHT - 10, 80, BUTTON_HEIGHT);
  log_but.setColorBackground(color(18,196,138));
  log_but.setCaptionLabel("Start Logging");

  plotOptions = controlP5.addCheckBox("Plot Options", X_BASE, Y_BASE - 30);
  plotOptions.addItem("Overlay", 0);
  plotOptions.addItem("Test Color", 0);
  plotOptions.addItem("Crosshair", 0);
  plotOptions.setItemsPerRow(3);
  plotOptions.setSpacingColumn(50);

  nasa_logo = loadShape("nasa.svg");
  jpl_logo = loadShape("jpl.svg");
  jpl_logo.scale(0.8);
  nasa_logo.scale(0.4);
  
  normPlot = new LinePlot("Norm", 60, 500, 1120, 150);
  normPlot.setBgColor(BOX_BG_COLOR);
  
}

/*
 * The draw() function is called at 30 FPS.
 */
void draw() 
{
  background(BG_COLOR);

  drawSerialSettings(); 

  textSize(35);
  textAlign(CENTER,CENTER);
  text("Tactile Wheel Interface", WINDOW_W/2, 50);
  
  textSize(12);
  textAlign(LEFT, CENTER);
  fill(FONT_COLOR);
  
  if (mouseDebug)
  { 
    heatMap.trackMouse();
   for (int i=0; i<NUM_COLS; i++)
   {
     normPlot.setY(i, floor(heatMap.getColumnNorm(i)));
   } 
 }
  
  heatMap.draw();

  drawLogos();
  
  normPlot.draw();

  if (mouseCrosshair)
  { drawMouseCrosshair();}
}

void drawLogos()
{
  shapeMode(CENTER);
  shape(nasa_logo, 1200, 130);
  shape(jpl_logo, 980, 70);
}

/*
 * Customize settings for dropdown menus.
 */
void customizeDropdownList(DropdownList ddl, String[] optList) 
{
  ddl.setItemHeight(20);
  ddl.setBarHeight(20);
  ddl.captionLabel().style().marginTop = 3;
  ddl.captionLabel().style().marginLeft = 3;
  ddl.valueLabel().style().marginTop = 3;

  for (int i=0;i< optList.length ;i++) 
  {
    ddl.addItem(optList[i], i);
  }

}

/*
 * Return String of selected dropdown menu.
 */
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
    int baudVal = DEFAULT_BAUD; //Integer.parseInt(ddlGetSelected(ddl_baud));
    println("Port: " + portName);
    println("Baud: " + baudVal);


    thePort = new Serial(this, portName, baudVal);
    //thePort.bufferUntil('\n'); //trigger a SerialEvent every time a new line gets fed in
    but1.setCaptionLabel("STOP");
    thePort.buffer(18);
    portOpen = true;

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
    if (line.length() < heatMap.getNumRows()*2+1)
    {
      System.out.printf("Line 0x%02X too short: %d\n", (byte)line.charAt(0), (int)line.length());
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

    System.out.printf("Got column %d (0x%X).\n", col, col);
    String now = String.format("%02d:%02d:%02d",hour(),minute(),second());
    if (logging)
    {
       logger.print(now + ", " + String.format("%02d",col)); 
    }
    
    int runningSum = 0;
    for (int ii = 0; ii < heatMap.getNumRows(); ii++)
    { 
      int MSB = line.charAt(2*ii +1) % 256;
      int LSB = line.charAt(2*ii +2) % 256;
      int thisRead = MSB*256 + LSB;
      System.out.printf("%d: (0x%02X,0x%02X) = %d,%d = %d\n", ii, (byte)MSB, (byte)LSB, MSB, LSB, thisRead);
      
      
      if (thisRead <= 1023 && thisRead >= 0)
      {
        heatMap.setLevel(28*ii+col, 1023 - thisRead);
        runningSum += (1023 - thisRead);
        if (logging)
        {
          logger.print(", " + String.format("%4d",1023 - thisRead)); 
        }
      }   
     }
     if (logging)
      {
      logger.println("");
      } 
      
     normPlot.setY(col,floor(runningSum/float(heatMap.getNumRows())));
      
      
  }
  catch (Exception e) {
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
  text("(" + mouseX +"," + mouseY +")", mouseX+2, mouseY); 
  line(mouseX, mouseY - 5, mouseX, mouseY + 5);
  line(mouseX- 5, mouseY, mouseX+5, mouseY);
}

/*
 * Draw the Serial Settings box.
 */
void drawSerialSettings()
{
  //Draw framing box
  fill(BOX_BG_COLOR);
  stroke(255);
  rect(X_SERIAL, Y_SERIAL - 50, 350, 70); 

  textSize(14);
  textAlign(CENTER, CENTER);
  fill(FONT_COLOR);
  text("Serial Settings", X_SERIAL + 350/2  , Y_SERIAL - 40);
  textSize(12);
  
  if (portOpen)
  {
    but1.setColorBackground(CONNECTED_COLOR);
    but1.setCaptionLabel("STOP"); 
  }
  else
  {
    but1.setColorBackground(DISCONNECTED_COLOR);
    but1.setCaptionLabel("Connect"); 
  }
}


/*
 * React to keyboard events. 
 */
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
    if (logging)
    {
      println("Closing log file...");
      logger.flush();
      logger.close();
    }
    exit();
    break;
  case 'm':
    mouseDebug = !mouseDebug; 
    plotOptions.toggle(1);
    break;  
  case 'c':
    mouseCrosshair = !mouseCrosshair; 
    plotOptions.toggle(2);
    break;
  case 'o':
    showOverlay = !showOverlay; 
    plotOptions.toggle(0);
    break;

  default:
    println("No action defined for '" + c + "'.");
  }
}

 

/*
 * React to the checkbox events.
 */
void controlEvent(ControlEvent theEvent) {
  if (theEvent.isFrom(plotOptions)) 
  {
    showOverlay = plotOptions.getState(0); 
    mouseDebug = plotOptions.getState(1);
    mouseCrosshair = plotOptions.getState(2);
  }
}

/*
 * React to a push of the log button.
 */ 
void log_button(float theValue)
{
  if (!logging)
 {
    logger = createWriter("log_" + hour() + "_" + minute() + "_" + second() +".txt");
    log_but.setColorBackground(color(255, 0, 0));
    log_but.setCaptionLabel("Stop Logging");
    logging = true;
 }
 else
 {
    logger.flush();
    logger.close();
    log_but.setColorBackground(color(18,196,138));
    log_but.setCaptionLabel("Start Logging");    
    logging = false; 
 }
}
