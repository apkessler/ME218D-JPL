class LinePlot 
{
  
  String label;
  String x_axis_label = "x-axis";
  String y_axis_label = "y-axis";
  int plot_x;
  int plot_y;
  int plot_width;
  int plot_height;
  int Y_MAX = 1024;
  int NUM_VALS = 28;
  int DOT_RADIUS = 2;
  
  int[] yData = new int[NUM_VALS];
  int[] xData = new int[NUM_VALS];
  
  
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
     yData[i] = 512;  
    }
     
  }
  
  
  void draw()
  {
   textSize(10);
   fill(color(255,255,255));
   stroke(0);
   rectMode(CORNER);
   rect(plot_x, plot_y, plot_width, plot_height); 
    float x_pixel, y_pixel;
  for (int i = 0; i <NUM_VALS; i++)
  {
     
     x_pixel = 20+ map(xData[i], 0, NUM_VALS, plot_x, plot_x + plot_width);
     y_pixel = map(yData[i], 0, Y_MAX, plot_y, plot_y + plot_height);
     ellipseMode(RADIUS);
     fill(color(0,0,255));
     noStroke();
     ellipse(( int) x_pixel, (int) y_pixel, DOT_RADIUS, DOT_RADIUS);
    
  }
  
  fill(255); 
  text(x_axis_label, plot_x + plot_width/2, plot_y + plot_height+10);

  //translate(plot_x - 10, plot_y + plot_height/2);
  //rotate(-PI/2);
  //text(y_axis_label, 0, 0); 
  //rotate(PI/2);
    
  }
  
  
  
  
}
