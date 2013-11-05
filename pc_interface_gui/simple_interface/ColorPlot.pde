class ColorPlot {
  

   int xPos;
   int yPos;
  
   int hBox = 50;
   int wBox = 50;
   
   color strokeColor = color(255);
   color textColor = color(255);
  
   String label;

   int reading_max;
   int level;
   
   boolean showLabel;
   boolean showValue;
  
   
   color colorMap[];
   
   
   ColorPlot(String _label,int _x, int _y, int _w, int _h, color[] _map)
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
  
  void draw(boolean showOverlay)
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
  
  void setLevel(int _level)
  {
   level = _level; 
  }
  
  void setShowLabel(boolean _showLabel)
  {
   showLabel = _showLabel; 
  }
  
  void setShowValue(boolean _showValue)
  {
   showValue = _showValue; 
  }
  void setTextColor(color c)
  {
   textColor = c; 
  }
  
  void setShowOverlay(boolean _showOverlay)
  {
   showOverlay = _showOverlay; 
  }
  
  
}
