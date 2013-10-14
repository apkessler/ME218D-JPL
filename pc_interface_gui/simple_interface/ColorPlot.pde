class ColorPlot {
  

   int xPos;
   int yPos;
  
   int hBox = 50;
   int wBox = 50;
   
   color strokeColor = color(255);
   color textColor = color(255);
  
   String label;
   float level;
   
   boolean showLabel;
   
   color colorMap[];
   
   
   ColorPlot(String _label,int _x, int _y, int _w, int _h, color[] _map)
   {
      xPos = _x;
      yPos = _y;
      wBox = _w;
      hBox = _h;
      label = _label;
      level = 0.0;
      showLabel = true;
      
      colorMap = _map;
   }
  
  void draw()
  {   
   rectMode(CORNER);
   int cInd = floor(min(level*colorMap.length, 1023));
   fill(colorMap[cInd]);
   stroke(strokeColor);
   rect(xPos,yPos,wBox,hBox); 


   fill(textColor);
   if (showLabel)
   {
     textSize(10);
     text(label,xPos+wBox/2,yPos+hBox+10);
   }
   textSize(9);
   text(" " + floor(100*level) + "%",xPos + wBox, yPos + floor((1-level)*hBox));
  }
  
  void setLevel(float _level)
  {
   level = _level; 
  }
  
  void setShowLabel(boolean _showLabel)
  {
   showLabel = _showLabel; 
  }
  
  
  void setTextColor(color c)
  {
   textColor = c; 
  }
  
  
  
}
