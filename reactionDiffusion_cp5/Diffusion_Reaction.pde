
public void reactionDiffusion()
{
  for (int i=0; i<col; i++)
  {
    for (int j=0; j<row; j++)
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
  if (i > 1 && i < col-1 && j > 1 && j < row-1)
  {
    sum += cellList[i-1][j].getChemical(chemical) * near;
    sum += cellList[i+1][j].getChemical(chemical) * near;
    sum += cellList[i][j+1].getChemical(chemical) * near;
    sum += cellList[i][j-1].getChemical(chemical) * near;

    sum += cellList[i-1][j-1].getChemical(chemical) * far;
    sum += cellList[i+1][j-1].getChemical(chemical) * far;
    sum += cellList[i+1][j+1].getChemical(chemical) * far;
    sum += cellList[i-1][j+1].getChemical(chemical) * far;
  } else
  {
    sum = 0.0;
  }

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
   }
   */

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

  float res = 1;
  float marginX = (col * res) / 2.0;
  float marginY = (row * res) / 2.0;
  grid = createShape();
  grid.beginShape(TRIANGLE);
  grid.textureMode(NORMAL);
  grid.texture(buffer);
  grid.noStroke();
  for (int i=0; i<col; i++)
  {
    for (int j=0; j<row; j++)
    {
      grid.vertex(marginX - i * res, 0, marginY - j* res, norm(i, 0, col), norm(j, 0, row));      
      grid.vertex(marginX - i * res, 0, marginY - (j+1)* res, norm(i, 0, col), norm(j+1, 0, row)); 
      grid.vertex(marginX -(i+1) * res, 0, marginY - j * res, norm(i+1, 0, col), norm(j, 0, row));

      grid.vertex(marginX - (i+1) * res, 0, marginY - j * res, norm(i+1, 0, col), norm(j, 0, row));  
      grid.vertex(marginX - i * res, 0, marginY - (j+1)* res, norm(i, 0, col), norm(j+1, 0, row));  
      grid.vertex(marginX - (i+1) * res, 0, marginY - (j+1)* res, norm(i+1, 0, col), norm(j+1, 0, row));
    }
  }
  grid.endShape();
}