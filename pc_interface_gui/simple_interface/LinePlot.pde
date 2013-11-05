class LinePlot 
{
  color line_color = color(255);
  color grid_color = color(255);
  color dot_fill_color = color(255);
  color dot_outline_color = color(0);
  color bg_color = color(255);
  
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
  
  
  void draw()
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
     yPixels[i] = floor(plot_y + plot_height*(1 - float(yData[i])/(Y_MAX - Y_MIN)));
    
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
  
  
  void setY(int ind, int yval)
  {
    yData[ind] = yval;
  }


  void setBgColor(color c)
  {
    bg_color = c;
  }  
}
