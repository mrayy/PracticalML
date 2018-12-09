
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

PImage canvasImg;
JPGEncoder jpg=new JPGEncoder();

int targetWidth=512;
int targetHeight=512;
 
byte[] data=new byte[targetWidth*targetHeight];
  
String currentLabel="";
int currentIndex=0;

boolean _clear=false;

void setupOSC()
{
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,4200);
  dest = new NetAddress("127.0.0.1",9000);
  
}

void setup() {
    size(640,480);
    clearCanvas();
    
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
  if(_clear==true)
  {
   clearCanvas();
   _clear=false;
  }
  
}

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
   if(key=='n')
     sendNext();
   if(key=='r')
     sendReset();
   if(key=='q')
     sendQuit();
     
     
  if(key=='c')
  {
    clearCanvas();
  }
  
  if(key==' ')
  {
    sendOsc(ProcessImage());
  }
}


void mouseDragged() 
{ 
    strokeWeight(50);
    line(mouseX, mouseY, pmouseX, pmouseY);
    loop();
    
}

void mouseReleased()
{
   // sendOsc(ProcessImage());
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
  try{
  byte[] encoded = jpg.encode(img, 0.2F);
    msg.add(encoded);
  oscP5.send(msg, dest);
  }catch(Exception e)
  {
  }
  /*
  //send inputs
  for(int i=0;i<img.width*img.height;i++)
   {
     byte v=(byte)(255-brightness(img.pixels[i]));//each pixel value is 0->255, however we need to make it to be 0->1 for training
     data[i]=v;
   }*/
    
}


//This is called automatically when OSC message is received
void oscEvent(OscMessage theOscMessage) {
 if (theOscMessage.checkAddrPattern("/output/label")==true) {
     println(theOscMessage.typetag());
     if(theOscMessage.checkTypetag("is")) {
       currentIndex=theOscMessage.get(0).intValue();
       currentLabel=theOscMessage.get(1).stringValue();
       _clear=true;
     }
 }
 if (theOscMessage.checkAddrPattern("/output/done")==true) {
 }
}

void clearCanvas()
{
  clear();
  print(currentLabel);
    background(255);
  fill(0, 0, 0);
  text( "Draw by pressing mouse left button", 5, 15 );
  text( "Press C to clear", 5, 30 );
  text("Current Label:" + currentLabel, 10, 45);
}
