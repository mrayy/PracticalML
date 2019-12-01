/**
* PML: capture image and apply face detector on it, then send it using OSC to wekinator
**/

//import your libraries

import gab.opencv.*;
import processing.video.*;
import java.awt.*;

OpenCV opencv;
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress dest;
PFont f;


boolean newImage=false;

//define your variables
Capture cam;
int TargetWidth=25;
int TargetHeight=25;

PImage sentImage;

void setup() {

  size(640, 240);
  noStroke();
  smooth();
  
  
  printArray(Capture.list());
  f = createFont("Courier", 16);
  textFont(f);
  
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,9001);
  dest = new NetAddress("127.0.0.1",9000);
  
  //run your code
  // The camera can be initialized directly using an 
  // element from the array returned by list():
  cam = new Capture(this, 640/2, 480/2,Capture.list()[0]);
  cam.start(); 
  
  //prepare computer vision library for face detection
  opencv = new OpenCV(this, 640/2, 480/2);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  
  
  sentImage=createImage(TargetWidth,TargetHeight,ALPHA);
  
}

void draw() {
  
  //check if camera has new image
  if (newImage) 
  {
    newImage=false;
    fill(255);
    
    //run face detector on the image
    opencv.loadImage(cam);
    Rectangle[] faces = opencv.detect();
    println(faces.length);
    
    if(faces.length>0)
    {
      //crop the image
      PImage img=cam.get(faces[0].x, faces[0].y-10, faces[0].width, faces[0].height+20);
      //resize it to the target dimensions
      img.resize(TargetWidth,TargetHeight);
      //send it to Wekinator
      sendOsc(img);
      //display the original face vs the sent one
      image(img,0,0,width/2,height);
      image(sentImage,width/2,0,width/2,height);
      text("Set Wekinator Input Length to:" + TargetWidth*TargetHeight, 10, 80);
    }
  }
}

void captureEvent(Capture c) {
  c.read();
  newImage=true;
}

void sendOsc(PImage img) {
  OscMessage msg = new OscMessage("/wek/inputs");
  
  sentImage.loadPixels();
  img.loadPixels();
  //send inputs
  for (int y = 0; y < TargetHeight; y++) {
    for (int x = 0; x < TargetWidth; x++) {
      int i = x + y*TargetWidth;
      float c=brightness(img.pixels[i]);
      //each pixel value is 0->255, however we need to make it to be 0->1 for training
      msg.add(c/255.0);
      sentImage.pixels[i]=color(c);
    }
  } 
  
  
  sentImage.updatePixels();
  oscP5.send(msg, dest);
}
