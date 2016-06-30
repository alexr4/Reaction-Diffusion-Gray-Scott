//Reaction diffusion tutorial from : https://www.youtube.com/watch?v=BV9ny785UNc && http://www.karlsims.com/rd.html
/*
Each cell has an amount of chemical
 per cell :
 Chemical A is add at a feed rate
 2 B convert an A
 B is remove at a kill rate
 */
import peasy.*;
import controlP5.*;

PeasyCam cam;
ControlP5 cp5;


//Reaction Diffusion Model
PGraphics buffer;
int gridWidth;
int gridHeight;
int row, col;
int margin;
float resX, resY;

Cell[][] cellList;
Cell[][] nextCellList;


//diffusion Rate
float dA = 1.0;
float dB = 0.5;

//kill rate
float killRate = 0.061;//0.045;//0.054;//0.058;//0.057;//0.061;//0.062;

//feed rate
float feedRate = 0.062;//0.014;//0.014;//0.039;//0.029;//0.078;//0.05;

//neighbors level
float near = 0.2;
float far = 0.05;

//scaleShape
float scale = 10;

PShader displacement;
float shaderStrength;
int blur;

PShape grid;

void setup()
{
  size(1280, 720, P3D);


  //Reaction Diffusion Model
  gridWidth = 600;
  gridHeight = gridWidth;
  margin = 0;
  col = gridWidth;
  row = gridHeight;//(int) (col * ((float) gridWidth / (float) gridHeight));
  resX = (gridWidth - margin*2) / row;
  resY = (gridHeight - margin*2) / col;
  cellList = new Cell[col][row];
  nextCellList = new Cell[col][row];
  init((int)random(10, 50));
  buffer = createGraphics(col, row, P3D);
  buffer.loadPixels();

  println(buffer.width*buffer.height, gridWidth * gridHeight);

  cam = new PeasyCam(this, 0, 0, 0, 500);



  initCP5(150);

  displacement = loadShader("displacement_frag.glsl", "displacement_vert.glsl");
  displacement.set("displacementMap", buffer);
  displacement.set("displaceStrength", shaderStrength);
   displacement.set("kd", 0.25, 0.25, 0.25);
  displacement.set("ka", 0.25, 0.25, 0.25);
  displacement.set("ks", 0.25, 0.25, 0.25);
  displacement.set("emissive", 0.0, 0.0, 0.0);
  displacement.set("shininess", 50.0);
  
  frameRate(1000);
}

void draw()
{
  updateDiffusionReactionValue();
  background(127);

  thread("reactionDiffusion");

  //update Texture
  for (int i=0; i<col; i++)
  {
    for (int j=0; j<row; j++)
    {
      Cell c = cellList[i][j];
      float a = c.a;//contrast(c.a, 0.25);
      float b = c.b;//contrast(c.b, 0.25);
      int index = floor(i + j * buffer.width);
      buffer.pixels[index] = color(a * 255, b*255, 0);//(a-b) * 255);
    }
  }
  buffer.updatePixels();
  ImageComputation.fastblur(buffer, blur);


  //lights();
  //lightFalloff(1.0, 0.001, 0.0);
 // pointLight(127, 127, 127, -500, -500, 500);
  //lightFalloff(10.0, 0.001, 0.0);
  pointLight(255, 255, 255, 0, 50, 0);
  pushStyle();
  strokeWeight(10);
  stroke(255);
  point(0, 50, 0);
  popStyle();
  pushStyle();
  noStroke();
  fill(255);
  shader(displacement);
 /* sphereDetail(600);
  sphere(250);*/
  shape(grid);
  popStyle();
  resetShader();






  surface.setTitle("Fps : "+frameRate);

  gui();
}


void keyPressed()
{
  init((int)random(10, 50));
}