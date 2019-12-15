
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


final int FeaturesCount= 17*2; //set the number of features your program generates
float[] features=new float[FeaturesCount];


// This array will hold all the humans detected
JSONObject data;
JSONArray pose;

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
    //Display some information
  text("Continuously sends **** ("+FeaturesCount+" inputs) to Wekinator\nUsing message /wek/inputs, to port 6448", 10, 30);

  sendFrameToRunway();
  // draw webcam image
  if(RMLImage!=null){
    image(RMLImage,0,0,width,height);
  }
  
  stroke(255);
  // use the utiliy class to draw PoseNet parts
  if(pose != null){
    for (int k = 0; k < pose.size(); k++) {
      // Body parts are relative to width and weight of the input
      JSONArray point = pose.getJSONArray(k);
      float x = point.getFloat(0)*width;
      float y = point.getFloat(1)*height;
      
      fill(255);
      ellipse(x , y, 10, 10);
      
      fill(255,0,0);
      text(str(k),x,y);
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
  JSONArray poses = data.getJSONArray("poses");
  if (poses != null)
  {
    print("Received Data length: ");
    
    if(poses.size()==0)
      return; //no poses detected
    
    pose=poses.getJSONArray(0);//get the first person
    println(pose.size());
    
    for (int i = 0; i < pose.size(); i++) {
      JSONArray point = pose.getJSONArray(i);
      features[i*2+0]=point.getFloat(0); //get X value
      features[i*2+1]=point.getFloat(1); //get Y value
    }
    sendOSC();
  }
    
}
