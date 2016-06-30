//Reaction diffusion tutorial from : https://www.youtube.com/watch?v=BV9ny785UNc && http://www.karlsims.com/rd.html
/*
Each cell has an amount of chemical
 per cell :
 Chemical A is add at a feed rate
 2 B convert an A
 B is remove at a kill rate
 */
import peasy.*;

PeasyCam cam;

int row, col;
int margin;
float resX, resY;

Cell[][] cellList;
Cell[][] nextCellList;


//diffusion Rate
float dA = 1.0;
float dB = 0.5;

//feed rate
float feedRate = 0.062;//0.014;//0.014;//0.039;//0.029;//0.078;//0.05;

//kill rate
float killRate = 0.061;//0.045;//0.054;//0.058;//0.057;//0.061;//0.062;

//neighbors level
float near = 0.2;
float far = 0.05;

//scaleShape
float scale = 10;

void setup()
{
  size(1280, 720, P3D);

  int gridWidth = 150;
  int gridHeight = gridWidth;
  margin = 0;
  col = gridWidth;
  row = (int) (col * ((float) gridWidth / (float) gridHeight));
  resX = (gridWidth - margin*2) / row;
  resY = (gridHeight - margin*2) / col;
  cellList = new Cell[col][row];
  nextCellList = new Cell[col][row];

  init((int)random(10, 50));
  cam = new PeasyCam(this, gridWidth/2 * scale, gridHeight/2 * scale, 0, 500);
}

void draw()
{
  background(127);

  thread("reactionDiffusion");

  loadPixels();
  for (int i=1; i<col-1; i++)
  {
    for (int j=1; j<row-1; j++)
    {
      Cell c = cellList[i][j];
      float a = c.a;//contrast(c.a, 0.25);
      float b = c.b;//contrast(c.b, 0.25);
      int index = i + j * width;
      pixels[index] = color((a-b) * 255);
    }
  }
  updatePixels();


  lights();
  pushStyle();
  fill(200);
  stroke(0, 160, 255, 10);
  beginShape(TRIANGLES);
  float hm = 100;
  for (int i=1; i<col-1; i++)
  {
    for (int j=1; j<row-1; j++)
    {
      Cell c0 = cellList[i][j];
      Cell c1 = cellList[i+1][j];
      Cell c2 = cellList[i][j+1];
      Cell c3 = cellList[i+1][j+1];

      c0.displayParticle(g, scale, hm);
      c2.displayParticle(g, scale, hm);
      c1.displayParticle(g, scale, hm);

      c1.displayParticle(g, scale, hm);
      c2.displayParticle(g, scale, hm);
      c3.displayParticle(g, scale, hm);
    }
  }
  endShape();




  surface.setTitle("Fps : "+frameRate);
}

void keyPressed()
{

  init((int)random(10, 50));
}

public void reactionDiffusion()
{
  for (int i=1; i<col-1; i++)
  {
    for (int j=1; j<row-1; j++)
    {
      Cell c = cellList[i][j];
      Cell n = nextCellList[i][j];

      //kill rate varies along the x axis (from .045 to .07) and the feed rate varies along the y axis (from .01 to .1)
      PVector vector = new PVector(i, j);
      PVector center = new PVector(col/2, row/2);
      float d = PVector.dist(vector, center);
      //killRate = map(d, 0, sqrt(col * col + row * row), .07, .045);
      //feedRate = map(d, 0, sqrt(col * col + row * row), .1, .001);

      //reaction formula
      n.a = c.a + 
        (dA * laplace(i, j, 0)) -
        (c.a * c.b * c.b) +
        (feedRate * (1.0 - c.a)) * 1;
      n.b = c.b + 
        (dB * laplace(i, j, 1)) +
        (c.a * c.b * c.b) -
        ((killRate + feedRate) * c.b) * 1;

      n.a = constrain(n.a, 0.0, 1.0);
      n.b = constrain(n.b, 0.0, 1.0);

      //n.display(g);
      //c.displayGrid(g);
    }
  }
  swapGrid();
}

public void swapGrid()
{
  Cell[][] temp = cellList;
  cellList = nextCellList;
  nextCellList = temp;
}

public float laplace(int i, int j, int chemical)
{
  float sum = 0;

  sum += cellList[i][j].getChemical(chemical) * -1;
  sum += cellList[i-1][j].getChemical(chemical) * near;
  sum += cellList[i+1][j].getChemical(chemical) * near;
  sum += cellList[i][j+1].getChemical(chemical) * near;
  sum += cellList[i][j-1].getChemical(chemical) * near;
  sum += cellList[i-1][j-1].getChemical(chemical) * far;
  sum += cellList[i+1][j-1].getChemical(chemical) * far;
  sum += cellList[i+1][j+1].getChemical(chemical) * far;
  sum += cellList[i-1][j+1].getChemical(chemical) * far;

  return sum;
}

public float contrast(float n, float offset)
{
  float value;
  if (n > offset)
  {
    value = 1.0;
  } else
  {
    value = 0.0;
  }

  return value;
}

public void init(int nbCellFeeded)
{
  for (int i=0; i<col; i++)
  {
    for (int j=0; j<row; j++)
    {
      float x = margin  + resX/2 + i * resX;
      float y = margin + resY/2 + j * resY ;
      cellList[i][j] = new Cell(x, y, resX, resY, 1, 0);
      nextCellList[i][j] = new Cell(x, y, resX, resY, 1, 0);
    }
  }

  //center
  /*
  int radius = int(random(col/8, col/2));
   for (int k=0; k<nbCellFeeded; k++)
   {
   float theta = norm(k, 0, nbCellFeeded) * TWO_PI;
   int x = int(col/2 + cos(theta) * radius);
   int y = int(row/2 + sin(theta) * radius);
   float innerRadius = random(2, 8);
   for (int i=0; i<360; i++)
   {
   float gamma = norm(i, 0, 360) * TWO_PI;
   int ii = int(x + cos(gamma) * innerRadius);
   int ij = int(y + sin(gamma) * innerRadius);
   ii = constrain(ii, 0, col);
   ij = constrain(ij, 0, row);
   
   cellList[ii][ij].b = 1;
   cellList[ii][ij].a = 1;
   }
   }*/


  for (int k=0; k< nbCellFeeded; k++)
  {
    int limitCol = (int) random(2, 8);
    int limitRow = (int) random(2, 8);
    int ii = (int) random(limitCol, col-limitCol);
    int ij = (int) random(limitRow, row-limitRow);

    for (int i=ii - limitCol; i<ii + limitCol; i++)
    {
      for (int j=ij - limitRow; j<ij + limitRow; j++)
      {
        cellList[i][j].b = 1;
      }
    }
  }
}