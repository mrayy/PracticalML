/**
* Simple example to capture web camera images, and send it to Wekinator
**/

import oscP5.*;
import netP5.*;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;
import javax.imageio.ImageWriter;
import javax.imageio.ImageWriteParam;
import javax.imageio.stream.MemoryCacheImageOutputStream;
import javax.imageio.IIOImage;
import java.io.ByteArrayOutputStream;
import java.io.ByteArrayInputStream;

public class JPGEncoder {

  byte[] encode(PImage img, float compression) throws IOException {
    ByteArrayOutputStream baos = new ByteArrayOutputStream();
    
    ImageWriter writer = ImageIO.getImageWritersByFormatName("jpeg").next();
    ImageWriteParam param = writer.getDefaultWriteParam();
    param.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
    param.setCompressionQuality(compression);

    // ImageIO.write((BufferedImage) img.getNative(), "jpg", baos);
    writer.setOutput(new MemoryCacheImageOutputStream(baos));

    writer.write(null, new IIOImage((BufferedImage) img.getNative(), null, null), param);

    return baos.toByteArray();
  }

  byte[] encode(PImage img) throws IOException {
    return encode(img, 0.5F);
  }

  PImage decode(byte[] imgbytes) throws IOException, NullPointerException {
    BufferedImage imgbuf = ImageIO.read(new ByteArrayInputStream(imgbytes));
    PImage img = new PImage(imgbuf.getWidth(), imgbuf.getHeight(), RGB);
    imgbuf.getRGB(0, 0, img.width, img.height, img.pixels, 0, img.width);
    img.updatePixels();

    return img; 
  }

}


OscP5 oscP5;
NetAddress dest;
PFont f;

//import your libraries
import processing.video.*;

//define your variables
Capture cam;
int TargetWidth=64;
int TargetHeight=64;
JPGEncoder jpg=new JPGEncoder();

String currentLabel="";
int currentIndex=0;
boolean isDone=false;

boolean recording=false;
int total_images=0;
int counter=0;

void setupWekinator()
{
  /* start oscP5, listening for incoming messages at port 4200 */
  oscP5 = new OscP5(this,4200);
  dest = new NetAddress("127.0.0.1",9000);
  
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
  
  sendReset();
}

boolean takePicture=false;

void sendNext()
{
  OscMessage msg = new OscMessage("/inputs/next");
  oscP5.send(msg, dest);
}
void sendReset()
{
  OscMessage msg = new OscMessage("/inputs/reset");
  oscP5.send(msg, dest);
}
void sendQuit()
{
  OscMessage msg = new OscMessage("/quit");
  oscP5.send(msg, dest);
}
void keyPressed()
{
  if(key==' ')
  {
    recording=!recording;
  }
   if(key=='n')
     sendNext();
   if(key=='r')
     sendReset();
   if(key=='q')
     sendQuit();
}

void draw() {
  
  //check if camera has new image
  if (cam.available() == true) {
    cam.read(); //Capture new camera image
    
      PImage img=cam.copy();//process camera input (Rescale it to smaller size)
      img.resize(TargetWidth,TargetHeight);//rescaling
    if(recording && counter>10)
    {
      counter=0;
      total_images=total_images+1;
      sendOsc(img);//send it to Wekinator
    }
    counter=counter+1;
    //display image
    background(0);
    fill(255);
    image(img, 0, 0,width,height);
    text("Current Label:" + currentLabel, 10, 80);
    if(recording)
      text("[Recording]", 10, 95);
    else
      text("[Stopped]", 10, 95);
      
    text("Total Images:"+total_images, 10, 110);
  
  }
}

void sendOsc(PImage img) {
  OscMessage msg = new OscMessage("/inputs/image");
  
  msg.add(img.width);
  msg.add(img.height);
  try{
    img.filter(GRAY);//apply a filter
  byte[] encoded = jpg.encode(img, 0.95F);
    msg.add(encoded);
  oscP5.send(msg, dest);
  println(encoded.length);
  }catch(Exception e)
  {
  }
}


//This is called automatically when OSC message is received
void oscEvent(OscMessage theOscMessage) {
 if (theOscMessage.checkAddrPattern("/output/label")==true) {
     println(theOscMessage.typetag());
     if(theOscMessage.checkTypetag("is")) {
       currentIndex=theOscMessage.get(0).intValue();
       currentLabel=theOscMessage.get(1).stringValue();
       total_images=0;
     }
 }
 if (theOscMessage.checkAddrPattern("/output/done")==true) {
 }
}
