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

  public void displayParticle(PGraphics g, float s, float heightOffset)
  {
    float z = a * heightOffset * -1;// (a - b) * heightOffset * -1;
    float o = 1.0 - (a - b);
    
    //g.fill(200, o * 255);
    g.vertex(x*s, y*s, z);
  }

  public float getChemical(int chemical)
  {
    if (chemical == 0)
    {
      return a;
    } else
    {
      return b;
    }
  }
}