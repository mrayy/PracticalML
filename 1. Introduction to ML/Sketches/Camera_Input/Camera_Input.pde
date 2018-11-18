/**
* Simple example to capture web camera images, and send it to Wekinator
**/

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress dest;
PFont f;

//import your libraries
import processing.video.*;

//define your variables
Capture cam;
int TargetWidth=25;
int TargetHeight=25;

void setupWekinator()
{
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,9000);
  dest = new NetAddress("127.0.0.1",6448);
  
}

void setup() {

  size(640, 480, P2D);
  noStroke();
  smooth();
  
  f = createFont("Courier", 16);
  textFont(f);
  
  setupWekinator();
  
  //run your code

  // The camera can be initialized directly using an 
  // element from the array returned by list():
  cam = new Capture(this, 640,480);
  cam.start(); 
  
  //internal, disable image filter when rendering
  ((PGraphicsOpenGL)g).textureSampling(3);
}

void draw() {
  
  //check if camera has new image
  if (cam.available() == true) {
    cam.read(); //Capture new camera image
    
    
    PImage img=cam.copy();//process camera input (Rescale it to smaller size)
    img.resize(TargetWidth,TargetHeight);//rescaling
    sendOsc(img);//send it to Wekinator
    
    //display image
    background(0);
    fill(255);
    image(img, 0, 0,width,height);
    text("Set Wekinator Input Length to:" + TargetWidth*TargetHeight, 10, 80);
  
  }
}

void sendOsc(PImage img) {
  OscMessage msg = new OscMessage("/wek/inputs");
  
  //send inputs
  for(int i=0;i<TargetWidth*TargetHeight;i++)
    msg.add((float)brightness(img.pixels[i])/255.0);//each pixel value is 0->255, however we need to make it to be 0->1 for training
    
  oscP5.send(msg, dest);
}
