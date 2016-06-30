public class Cell
{
  float cellWidth, cellHeight;
  float x, y;
  
  //chemical
  float a;
  float b;
  
  Cell(float x_, float y_, float w_, float h_, float a_, float b_)
  {
    x = x_;
    y = y_;
    cellWidth = w_;
    cellHeight = h_;
    a = a_;
    b = b_;
  }
  
  public void displayGrid(PGraphics g)
  {
    g.pushStyle();
    g.noFill();
    g.stroke(0, 255, 0);
    g.rectMode(CENTER);
    g.rect(x, y, cellWidth, cellHeight);
    g.noStroke();
    g.fill(0, 255, 0);
    g.ellipse(x, y, 4, 4);
    g.popStyle();
  }
  
   public void display(PGraphics g)
  {
    g.pushStyle();
    g.noStroke();
    g.fill((a - b) * 255);
    g.rectMode(CENTER);
    g.rect(x, y, cellWidth, cellHeight);
    g.popStyle();
  }
  
  public float getChemical(int chemical)
  {
    if(chemical == 0)
    {
      return a;
    }
    else
    {
      return b;
    }
  }
}