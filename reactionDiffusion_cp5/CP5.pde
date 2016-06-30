float diffusionA;
float diffusionB;
float kill;
float feed;
float displaceStrength;
float cpblur;

void initCP5(int h_)
{
  cp5 = new ControlP5(this);
  float y = 0;
  cp5.addSlider("diffusionA")
    .setPosition(10, h_ + 10)
    .setRange(0, 1.0)
    .setValue(0.65)
    ;

  y+= 20;
  cp5.addSlider("diffusionB")
    .setPosition(10, h_ + 10 + y)
    .setRange(0, 1.0)
    .setValue(0.16)
    ;

  y+= 20;
  cp5.addSlider("kill")
    .setPosition(10, h_ + 10 + y)
    .setRange(0, 1)
    .setValue(0.61)
    ;

  y+= 20;
  cp5.addSlider("feed")
    .setPosition(10, h_ + 10 + y)
    .setRange(0, 1)
    .setValue(0.78)
    ;
    
 y+= 20;
  cp5.addSlider("displaceStrength")
    .setPosition(10, h_ + 10 + y)
    .setRange(10, 100)
    .setValue(5.0)
    ;
    
       
 y+= 20;
  cp5.addSlider("cpblur")
    .setPosition(10, h_ + 10 + y)
    .setRange(1, 10)
    .setValue(2.0)
    ;

  cp5.setAutoDraw(false);
}

void gui() {
  hint(DISABLE_DEPTH_TEST);
  cam.beginHUD();
  noLights();
  image(buffer, 0, 0, 150, 150);
  cp5.draw();
  cam.endHUD();
  hint(ENABLE_DEPTH_TEST);
}

void updateDiffusionReactionValue()
{
  dA = diffusionA;
  dB = diffusionB;
  killRate = kill * 0.1;
  feedRate = feed * 0.1;
  shaderStrength = displaceStrength;
  displacement.set("displaceStrength", shaderStrength);
  blur = round(cpblur);
}