
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress dest;
PFont f;

PImage canvasImg;

int targetWidth=28;
int targetHeight=28;
 
void setupOSC()
{
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,4200);
  dest = new NetAddress("127.0.0.1",9000);
  
}

void setup() {
    size(640,480);
    clear();
    
    canvasImg = createImage(width,height,RGB);  // Make an image holder object
    setupOSC();
    
}
 void exit() {
    OscMessage msg = new OscMessage("/quit");
    oscP5.send(msg, dest);
    super.exit();
}

void loop()
{
}
void draw()
{
}

void mouseDragged() 
{ 
    strokeWeight(50);
    line(mouseX, mouseY, pmouseX, pmouseY);
    loop();
    
}

void mouseReleased()
{
    sendOsc(ProcessImage());
}
  

PImage ProcessImage()
{
  loadPixels();
  //copy screen to an image
  for(int i=0;i<width*height;i++)
    canvasImg.pixels[i]=pixels[i];
  
  PImage img=canvasImg.copy();//process camera input (Rescale it to smaller size)
  img.resize(targetWidth,targetHeight);//rescaling
  return img;
  
}


void sendOsc(PImage img) {
  OscMessage msg = new OscMessage("/inputs/image");
  
  msg.add(img.width);
  msg.add(img.height);
  //send inputs
  for(int i=0;i<img.width*img.height;i++)
    msg.add(1-(brightness(img.pixels[i])/255.0));//each pixel value is 0->255, however we need to make it to be 0->1 for training
    
  oscP5.send(msg, dest);
}

void clear()
{
  
    background(255);
  fill(0, 0, 0);
  text( "Draw by pressing mouse left button", 5, 15 );
  text( "Press C to clear", 5, 30 );
}

void keyPressed()
{
  if(key=='c')
  {
    clear();
  }
  
  if(key==' ')
  {
    sendOsc(ProcessImage());
  }
}
