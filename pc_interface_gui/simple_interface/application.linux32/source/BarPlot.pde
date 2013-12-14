class BarPlot {
  

   int xPos;
   int yPos;
  
   int hBar = 200;
   int wBar = 50;
   color bg_color = color(191, 131, 48);
   color active_color = color(255,0,0);

  
   String label;
   float level;
   
   boolean showLabel;
   
   
   BarPlot(String _label,int _x, int _y)
   {
      xPos = _x;
      yPos = _y;
      label = _label;
      level = .2;
      showLabel = true;
   }
  
  void draw()
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
  
  void setLevel(float _level)
  {
   level = _level; 
  }
  
  void setShowLabel(boolean _showLabel)
  {
   showLabel = _showLabel; 
  }
  
  
  void setBackgroundColor(color c)
  {
   bg_color = c; 
  }
  
  void setForegroundColor(color c)
  {
   active_color = c; 
  }
  
  
}
