PShader reactionDiffusion;
PShader grayScale;
PGraphics buffer;

float t= 0;
float r=0;

boolean state;


void setup()
{
  size(1280, 547, P3D);
  //fullScreen(P3D);

  buffer = createGraphics(width, height, P3D);
  buffer.smooth();
  reactionDiffusion = loadShader("reactionDiffusion.glsl");
  grayScale = loadShader("reactionDiffusionRender.glsl");
  reactionDiffusion.set("screen", (float) width, (float) height);
  reactionDiffusion.set("mouse", float(width/2), float(height/2));

  frameRate(1000);
}

void draw()
{
  surface.setTitle("FPS : "+ round(frameRate)); 


  buffer.beginDraw();
  buffer.filter(reactionDiffusion);
  buffer.endDraw();

  //shader(grayScale);
  image(buffer, 0, 0);

  if (state)
  {
    update();
  }
}

void update()
{
  float theta = t * TWO_PI;
  float radius = r;// * (sqrt(width * width + height * height)/2);

  float nx = width/2 + cos(theta) * radius;
  float ny = height/2 + sin(theta) * radius;

  reactionDiffusion.set("mouse", nx, ny);
  reactionDiffusion.set("time", (float) millis()/1000.0);
  reactionDiffusion.set("maxDist", dist(width/2, height/2, nx, ny)/4);

  t += random(1);// 0.01;//random(1);
  r += 0.01;
}

void keyPressed()
{
  if (key == 's' || key == 'S')
  {
    state = !state;
  }
  if (key == 'r' || key == 'R')
  {
    t= 0;
    r=0;
    buffer.clear();
    buffer.beginDraw();
    buffer.background(255);
    buffer.endDraw();
  }
  if (key == 'l' || key == 'L')
  {
    grayScale = loadShader("reactionDiffusionRender.glsl");
  }
}