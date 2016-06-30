PShader shader;
float feed = 0.037;
float kill = 0.06;
float delta = 1.0;
 
void setup() {
  size(640, 360, P2D);
  shader = loadShader("reactionDiffusionDirect.glsl"); 
  shader.set("screen", float(width), float(height));
  shader.set("delta", delta);
  shader.set("feed", feed);
  shader.set("kill", kill);
}
 
void draw() {
  shader.set("mouse", float(mouseX), float(height-mouseY));
 // shader.set("delta", millis() / 10000.0);
  filter(shader);  
}