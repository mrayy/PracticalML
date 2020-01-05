
// face_landmarks Demo:
// Receive OSC messages from Runway
// Running face_landmarks model
// Sends features data to Wekinator

import oscP5.*;
import netP5.*;

// import Runway library
import com.runwayml.*;
// reference to runway instance
RunwayOSC runway;


OscP5 oscP5;
NetAddress dest;


final int FeaturesCount= 72*2; //set the number of features your program generates
float[] features=new float[FeaturesCount];


// This array will hold all the humans detected
JSONObject data;
JSONArray landmarks ;

void setup(){
  // match sketch size to default model camera setup
  size(600,400);
  fill(9,130,250);
  noStroke();
  // setup Runway
  runway = new RunwayOSC(this);
  
  
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,0);
  dest = new NetAddress("127.0.0.1",6448);
  
  setupRMLImage();
}

void draw(){
  background(0);
  fill(255);
    //Display some information
  text("Continuously sends **** ("+FeaturesCount+" inputs) to Wekinator\nUsing message /wek/inputs, to port 6448", 10, 30);

  sendFrameToRunway();
  // draw webcam image
  if(RMLImage!=null){
    image(RMLImage,0,0,width,height);
  }
  
  stroke(255);
  // use the utiliy class to draw face landmarks
  if (landmarks != null)
  {
    for (int k = 0; k < landmarks.size()-1; k++) {
      // Body parts are relative to width and weight of the input
      JSONArray point = landmarks.getJSONArray(k);
      float x = point.getFloat(0)*width;
      float y = point.getFloat(1)*height;
      
      
      JSONArray point2 = landmarks.getJSONArray(k+1);
      float x2 = point2.getFloat(0)*width;
      float y2 = point2.getFloat(1)*height;
      //ellipse(x * width, y * height, 10, 10);
      
      line(x,y,x2,y2);
    }
  }
}

void sendOSC()
{
  OscMessage msg = new OscMessage("/wek/inputs");
  
  for(int i=0;i<FeaturesCount;++i)
    msg.add((float)features[i]);
  oscP5.send(msg, dest);
}

// this is called when new Runway data is available
void runwayDataEvent(JSONObject runwayData){
  // point the sketch data to the Runway incoming data 
  data = runwayData;
  
  println("runway");
  
  if(data!=null)
  {
    landmarks = data.getJSONArray("points");
    if (landmarks != null)
    {
      print("Received Data length: ");
      println(landmarks.size());
      
      for (int i = 0; i < landmarks.size(); i++) {
        JSONArray point = landmarks.getJSONArray(i);
        features[i*2+0]=point.getFloat(0); //get X value
        features[i*2+1]=point.getFloat(1); //get Y value
      }
      sendOSC();
    }
  }
    
}
