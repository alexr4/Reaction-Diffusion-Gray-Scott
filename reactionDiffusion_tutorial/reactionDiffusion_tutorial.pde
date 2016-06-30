//Reaction diffusion tutorial from : https://www.youtube.com/watch?v=BV9ny785UNc && http://www.karlsims.com/rd.html
/*
Each cell has an amount of chemical
 per cell :
 Chemical A is add at a feed rate
 2 B convert an A
 B is remove at a kill rate
 */
int row, col;
int margin;
float resX, resY;

Cell[][] cellList;
Cell[][] nextCellList;

//diffusion Rate
float dA = 1.0;
float dB = 0.5;

//feed rate
float feedRate = 0.05;

//kill rate
float killRate = 0.062;

//neighbors level
float near = 0.2;
float far = 0.05;

void setup()
{
  size(500, 500, P3D);

  margin = 0;
  col = width;
  row = height;//(int) (col * ((float) width / (float) height));
  resX = (width - margin*2) / row;
  resY = (height - margin*2) / col;
  cellList = new Cell[col][row];
  nextCellList = new Cell[col][row];

  for (int i=0; i<col; i++)
  {
    for (int j=0; j<row; j++)
    {
      float x = margin + i * resX + resX/2;
      float y = margin + j * resY + resY/2;
      cellList[i][j] = new Cell(x, y, resX, resY, 1, 0);
      nextCellList[i][j] = new Cell(x, y, resX, resY, 1, 0);
    }
  }


  /*for (int k=0; k< 100; k++)
   {
   int radius = int(random(1, 2));
   int x = (int) random(radius, col-radius);
   int y = (int) random(radius, row-radius);
   for (int i=0; i<360; i++)
   {
   float gamma = norm(i, 0, 360) * TWO_PI;
   int ii = int(x + cos(gamma) * radius);
   int ij = int(y + sin(gamma) * radius);
   
   cellList[ii][ij].b = 1;
   }
   }*/


  for (int k=0; k< 100; k++)
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

void draw()
{
  background(127);

  for (int i=1; i<col-1; i++)
  {
    for (int j=1; j<row-1; j++)
    {
      Cell c = cellList[i][j];
      Cell n = nextCellList[i][j];

      //reaction formula
      n.a = constrain((c.a + 
        (dA * laplace(i, j, 0)) -
        (c.a * c.b * c.b) +
        (feedRate * (1.0 - c.a))), 0, 1);
      n.b = constrain((c.b + 
        (dB * laplace(i, j, 1)) +
        (c.a * c.b * c.b) -
        (killRate + feedRate) * c.b), 0, 1);


      //n.display(g);
      //c.displayGrid(g);
    }
  }
  swapGrid();

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


  surface.setTitle("Fps : "+frameRate);
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