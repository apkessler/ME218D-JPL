import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 
import controlP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class simple_interface extends PApplet {





/**************************************CONSTANTS*****************************************/
final int WINDOW_W = 1200;
final int WINDOW_H = 700;

final int Y_SERIAL = 70;
final int X_SERIAL = 20;
final int BUTTON_HEIGHT = 30;

//Colors...
final int DISCONNECTED_COLOR = color(40, 200, 6);
final int CONNECTED_COLOR = color(255, 0, 0);
final int BG_COLOR = color(20, 20, 20);
final int BOX_BG_COLOR = color(11, 95, 165);
final int FONT_COLOR = color(255);

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
float aniScale = 1.0f;

HeatMap heatMap;
PrintWriter logger;
boolean logging = false;

LinePlot normPlot;

/****************************************FUNCTIONS***************************************/
/*
 * The setup() functions get everything ready to go - executed
 * once before draw() is ever called.
 */
public void setup()
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
  jpl_logo.scale(0.8f);
  nasa_logo.scale(0.4f);
  
  normPlot = new LinePlot("Norm", 60, 500, 1120, 150);
  normPlot.setBgColor(BOX_BG_COLOR);
  
}

/*
 * The draw() function is called at 30 FPS.
 */
public void draw() 
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

public void drawLogos()
{
  shapeMode(CENTER);
  shape(nasa_logo, 1200, 130);
  shape(jpl_logo, 980, 70);
}

/*
 * Customize settings for dropdown menus.
 */
public void customizeDropdownList(DropdownList ddl, String[] optList) 
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
public String ddlGetSelected(DropdownList ddl)
{
  return ddl.getItem(PApplet.parseInt(ddl.getValue())).getName();
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
public void serialEvent(Serial _port) 
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
      
     normPlot.setY(col,floor(runningSum/PApplet.parseFloat(heatMap.getNumRows())));
      
      
  }
  catch (Exception e) {
    println(e);
  }
} 

/*
 * Draw a nice little crosshair over the pointer with coords so you can see where you are.
 */
public void drawMouseCrosshair()
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
public void drawSerialSettings()
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
public void keyPressed() 
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
public void controlEvent(ControlEvent theEvent) {
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
public void log_button(float theValue)
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
class BarPlot {
  

   int xPos;
   int yPos;
  
   int hBar = 200;
   int wBar = 50;
   int bg_color = color(191, 131, 48);
   int active_color = color(255,0,0);

  
   String label;
   float level;
   
   boolean showLabel;
   
   
   BarPlot(String _label,int _x, int _y)
   {
      xPos = _x;
      yPos = _y;
      label = _label;
      level = .2f;
      showLabel = true;
   }
  
  public void draw()
  {   
   rectMode(CORNER);
   fill(bg_color);
   rect(xPos,yPos,wBar,hBar); 
   fill(active_color);
   
   rect(xPos,yPos + floor((1-level)*hBar),wBar,floor(level*hBar));
   fill(color(0,0,0));
   if (showLabel)
   {
     textSize(10);
     text(label,xPos+wBar/2,yPos+hBar+10);
   }
   textSize(9);
   text(" " + floor(100*level) + "%",xPos + wBar, yPos + floor((1-level)*hBar));
  }
  
  public void setLevel(float _level)
  {
   level = _level; 
  }
  
  public void setShowLabel(boolean _showLabel)
  {
   showLabel = _showLabel; 
  }
  
  
  public void setBackgroundColor(int c)
  {
   bg_color = c; 
  }
  
  public void setForegroundColor(int c)
  {
   active_color = c; 
  }
  
  
}
class ColorPlot {
  

   int xPos;
   int yPos;
  
   int hBox = 50;
   int wBox = 50;
   
   int strokeColor = color(255);
   int textColor = color(255);
  
   String label;

   int reading_max;
   int level;
   
   boolean showLabel;
   boolean showValue;
  
   int colorMap[];
    
   ColorPlot(String _label,int _x, int _y, int _w, int _h, int[] _map)
   {
      xPos = _x;
      yPos = _y;
      wBox = _w;
      hBox = _h;
      label = _label;
      level = 0;
      showLabel = true;
      showValue = true;
      colorMap = _map;
   }
  
  public void draw(boolean showOverlay)
  {   
   rectMode(CORNER);
 
   fill(colorMap[level]);
   stroke(strokeColor);
   rect(xPos,yPos,wBox,hBox); 


   fill(textColor);
   if (showLabel)
   {
     textSize(10);
     text(label,xPos+wBox/2,yPos+hBox+10);
   }
   
   if (showValue)
   {
   textSize(9);
   text(" " + floor(100*level) + "%",xPos + wBox, yPos + floor((1-level)*hBox));
   }
   
   if (showOverlay || ((mouseX < (xPos + wBox)) && (mouseX > xPos) && (mouseY < (yPos + hBox)) && (mouseY > yPos)))
   {
     textSize(9);
     textAlign(CENTER,TOP);
     text(level,xPos + wBox/2, yPos + 2*hBox/3); 
     
     textAlign(CENTER, BOTTOM);
     text(label,xPos + wBox/2, yPos + hBox/3);
   }
   
  }
  
  public int getLevel()
  {
    return level; 
  }
  public void setLevel(int _level)
  {
   level = _level; 
  }
  
  public void setShowLabel(boolean _showLabel)
  {
   showLabel = _showLabel; 
  }
  
  public void setShowValue(boolean _showValue)
  {
   showValue = _showValue; 
  }
  public void setTextColor(int c)
  {
   textColor = c; 
  }
  
  public void setShowOverlay(boolean _showOverlay)
  {
   showOverlay = _showOverlay; 
  }
  
  
}
class HeatMap
{
  int BOX_BG_COLOR = color(11, 95, 165);
  int NUM_SENSORS = 224;
  int X_BASE = 20;
  int Y_BASE = 140;
  int X_SPACING = 0;
  int Y_SPACING = 0;
  int NUM_COLS;
  int NUM_ROWS;
  
  int W_BOX = 40;
  int H_BOX = 40;
  int X_BOX_BASE = X_BASE + 2*X_SPACING + W_BOX;
  int Y_BOX_BASE = Y_BASE + Y_SPACING;

  //Heat map...
  int NUM_COLORS = 1024;
  int[] colorMap;
  ColorPlot[] sensorPlots;


  HeatMap(int _x, int _y, int _n, int _c)
  {
    NUM_SENSORS = _n;
    X_BASE = _x;
    Y_BASE = _y; 
    colorMap =  new int[NUM_COLORS];
    sensorPlots = new ColorPlot[NUM_SENSORS];

    NUM_COLS = _c;
    NUM_ROWS = ceil(PApplet.parseFloat(NUM_SENSORS)/PApplet.parseFloat(NUM_COLS));
    int x_coord, y_coord;
    //Set up the positions of the bar graphs.
    for (int ii = 0; ii < NUM_SENSORS; ii++)
    {

      x_coord = (ii%NUM_COLS)*(W_BOX + X_SPACING) + X_BOX_BASE;
      y_coord = (ii/NUM_COLS)*(H_BOX + Y_SPACING) + Y_BOX_BASE;
      sensorPlots[ii] = new ColorPlot("S" + ii, x_coord, y_coord, W_BOX, H_BOX, colorMap); 
      sensorPlots[ii].setShowLabel(false);
      sensorPlots[ii].setShowValue(false);
    }
  }

  /* 
   * Load the color map from the text file.
   */
  public void loadColorMap()
  {
    String lines[] = loadStrings("jet.txt");
    for (int i=0; i < lines.length; i++)
    {
      String[] rgb = split(lines[i], ' ');
      colorMap[i] = color(Integer.parseInt(rgb[0]), Integer.parseInt(rgb[1]), Integer.parseInt(rgb[2]));
    }
  }

  public void draw()
  {

    //Draw the framing box
    fill(BOX_BG_COLOR);
    stroke(255);
    int frame_w = NUM_COLS * (W_BOX + X_SPACING) + 2*X_SPACING + W_BOX;
    int frame_h = NUM_ROWS * (H_BOX + Y_SPACING) + Y_SPACING;
    rect(X_BASE, Y_BASE, frame_w, frame_h); 

    //Draw all the bar graphs...
    for (int i = 0; i < NUM_SENSORS; i++)
    {
      sensorPlots[i].draw(showOverlay);
    }

    //Draw the graph text...
    fill(FONT_COLOR);
    textSize(20);
    textAlign(CENTER, CENTER);
    text("Force Sensors", X_BASE + frame_w/2, Y_BASE - 15);



    //drawMapLegend()
    int LEG_X = X_BASE + X_SPACING;
    int LEG_Y = Y_BASE + Y_SPACING;
    int LEG_WIDTH = W_BOX;
    int COLOR_HEIGHT = 1;
    int LEG_HEIGHT = NUM_ROWS*H_BOX + (NUM_ROWS - 1)*Y_SPACING;
    int NUM_LEG_COLORS = min(LEG_HEIGHT/COLOR_HEIGHT, 1024);

    noStroke();    
    fill(255);
    rect(LEG_X -1, LEG_Y - 1, LEG_WIDTH + 2, NUM_LEG_COLORS*COLOR_HEIGHT + 3);


    int ii;
    int cInd;
    for (ii = 0; ii < NUM_LEG_COLORS; ii++)
    {
      cInd = PApplet.parseInt(map(ii, 0, NUM_LEG_COLORS, 0, NUM_COLORS)); 
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
  
  
  public void trackMouse()
  {
   for (int i = 0; i < NUM_SENSORS; i++)
   {
     sensorPlots[i].setLevel(max(0,min(1023,floor(sin(PApplet.parseFloat(mouseX+i)/width*PI)*1023))));
   } 
  
  }
  
  public void setLevel(int i, int lvl)
  {
   sensorPlots[i].setLevel(lvl);  
  }
  
  
  public int getNumRows()
  {
   return NUM_ROWS; 
  }
  
  public int getColumnNorm(int col)
  {
    int runningSum = 0;
    for (int i = 0; i < NUM_ROWS; i++)
   {
     runningSum+= abs(sensorPlots[28*i+col].getLevel());
   } 
   return (floor(runningSum/PApplet.parseFloat(NUM_ROWS)));
  }
}



class LinePlot 
{
  int line_color = color(255);
  int grid_color = color(255);
  int dot_fill_color = color(255);
  int dot_outline_color = color(0);
  int bg_color = color(255);
  
  String label;
  String x_axis_label = "Col.";
  String y_axis_label = "|x|";
  
  int plot_x;
  int plot_y;
  int plot_width;
  int plot_height;
  int Y_MAX = 1024; // ceil(sqrt(1023^2 * 8))
  int Y_MIN = 0;
  int NUM_VALS = 28;
  int DOT_RADIUS = 4;
  
  int[] yData = new int[NUM_VALS];
  int[] xData = new int[NUM_VALS];
  
  int[] xPixels = new int[NUM_VALS];
  int[] yPixels = new int[NUM_VALS];
  
  boolean showGrid = false;
  
  LinePlot(String _label, int _x, int _y, int _w, int _h)
  {
    label = _label;
    
    plot_x = _x;
    plot_y = _y;
    
    plot_width = _w;
    plot_height = _h;
    
    for (int i = 0; i <NUM_VALS; i++)
    {
     xData[i] = i;
     yData[i] = Y_MAX/2;  
    }
     
  }
  
  
  public void draw()
  {
   textSize(10);
   fill(bg_color);
   stroke(255);
   rectMode(CORNER);
   rect(plot_x, plot_y, plot_width, plot_height); 
  
  if (showGrid)
  {
    for (int i = 1; i <NUM_VALS; i++)
    {
      stroke(grid_color);
      line(40*i + plot_x, plot_y, 40*i + plot_x, plot_y + plot_height);
    }
  }
    
   for (int i = 0; i <NUM_VALS; i++)
   {
     
     xPixels[i] = floor(20+ map(xData[i], 0, NUM_VALS, plot_x, plot_x + plot_width));
     yPixels[i] = floor(plot_y + plot_height*(1 - PApplet.parseFloat(yData[i])/(Y_MAX - Y_MIN)));
    
     //Draw the lines
     if (i > 0)
     {
       stroke(line_color);
       line(xPixels[i-1], yPixels[i-1], xPixels[i], yPixels[i]);
     }
     
  }
  
  //Draw the dots
  for (int i =0; i <NUM_VALS; i++)
  {
     fill(dot_fill_color);
     stroke(dot_outline_color);
     ellipseMode(RADIUS);
     ellipse(xPixels[i], yPixels[i], DOT_RADIUS, DOT_RADIUS); 
     textAlign(CENTER,BOTTOM);
     text(yData[i],xPixels[i],yPixels[i] - DOT_RADIUS);
  }
  
  fill(255); 
  textAlign(CENTER,CENTER);
  text(x_axis_label, plot_x + plot_width/2, plot_y + plot_height+10);
  text(y_axis_label, plot_x - 15, plot_y + plot_height/2);
    
  }
  
  
  public void setY(int ind, int yval)
  {
    yData[ind] = yval;
  }


  public void setBgColor(int c)
  {
    bg_color = c;
  }  
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "simple_interface" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
