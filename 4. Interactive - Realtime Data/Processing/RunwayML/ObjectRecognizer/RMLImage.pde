
// import video library
import processing.video.*;

// reference to the camera
Capture camera;

PImage RMLImage;
int ImageWidth=300;
int ImageHeight=200;

// periocally to be updated using millis()
int lastMillis;
// how often should the above be updated and a time action take place ?
// takes about 100-200ms for Runway to process a 600x400 PoseNet frame
int waitTime = 200;

void setupRMLImage()
{
  // setup camera
  camera = new Capture(this,640,480,Capture.list()[0]);
  camera.start();
  // setup timer
  lastMillis = millis();
}

void sendFrameToRunway(){
  // update timer
  int currentMillis = millis();
  // if the difference between current millis and last time we checked past the wait time
  if(currentMillis - lastMillis < waitTime)
    return;
  // update lastMillis, preparing for another wait
  lastMillis = currentMillis;
  
  // nothing to send if there's no new camera data available
  if(camera.available() == false){
    return;
  }
  // read a new frame
  camera.read();
  // crop image to Runway input format (600x400)
  RMLImage = camera.get(0,0,640,480);
  RMLImage.resize(ImageWidth,ImageHeight);
  // query Runway with webcam image 
  // query Runway with webcam image 
  runway.query(toRunwayImageQuery(RMLImage));
}

String QueryKey="image"; //change this depending on the used model query 

public String toRunwayImageQuery(PImage image){
  return "{\""+QueryKey+"\":\"" + ModelUtils.toBase64(image) + "\"}";
}
