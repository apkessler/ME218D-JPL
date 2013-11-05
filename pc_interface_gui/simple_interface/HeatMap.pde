class HeatMap
{
  color BOX_BG_COLOR = color(11, 95, 165);
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
  color[] colorMap;
  ColorPlot[] sensorPlots;


  HeatMap(int _x, int _y, int _n, int _c)
  {
    NUM_SENSORS = _n;
    X_BASE = _x;
    Y_BASE = _y; 
    colorMap =  new color[NUM_COLORS];
    sensorPlots = new ColorPlot[NUM_SENSORS];

    NUM_COLS = _c;
    NUM_ROWS = ceil(float(NUM_SENSORS)/float(NUM_COLS));
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
  void loadColorMap()
  {
    String lines[] = loadStrings("jet.txt");
    for (int i=0; i < lines.length; i++)
    {
      String[] rgb = split(lines[i], ' ');
      colorMap[i] = color(Integer.parseInt(rgb[0]), Integer.parseInt(rgb[1]), Integer.parseInt(rgb[2]));
    }
  }

  void draw()
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
  
  
  void trackMouse()
  {
   for (int i = 0; i < NUM_SENSORS; i++)
   {
     sensorPlots[i].setLevel(float(mouseX)/width);
   } 
  }
  
  void setLevel(int i, float lvl)
  {
   sensorPlots[i].setLevel(lvl);  
  }
  
  
  int getNumRows()
  {
   return NUM_ROWS; 
  }
}



