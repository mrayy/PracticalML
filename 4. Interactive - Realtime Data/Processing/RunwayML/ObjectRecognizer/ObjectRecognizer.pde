// COCO-SSD Demo:
// Receive OSC messages from Runway
// Running COCO-SSD model
import oscP5.*;
import netP5.*;

// import Runway library
import com.runwayml.*;
// reference to runway instance
RunwayOSC runway;
JSONArray labels,boxes;

OscP5 oscP5;
NetAddress dest;

final int FeaturesCount= 4; //set the number of features your program generates
float[] features=new float[FeaturesCount];


// This array will hold all the humans detected
JSONObject data;

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
  
  sendFrameToRunway();
  // draw webcam image
  if(RMLImage!=null){
    image(RMLImage,0,0,width,height);
  }
  
    //Display some information
  text("Continuously sends **** ("+FeaturesCount+" inputs) to Wekinator\nUsing message /wek/inputs, to port 6448", 10, 30);

  if(labels != null){
    for (int k = 0; k < labels.size(); k++) {
      JSONArray boxData=boxes.getJSONArray(k);
      
      
      float x=boxData.getFloat(0)*width;
      float y=boxData.getFloat(1)*height;
      float w=boxData.getFloat(2)*width - x;
      float h=boxData.getFloat(3)*height - y;
      noFill();
      stroke(255);
      rect(x,y,w,h);
      
      fill(255,0,0);
      text(labels.getString(k),x+20,y+20);
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
  if(data!=null)
  {
    boxes = data.getJSONArray("boxes");
    labels = data.getJSONArray("labels");
    if (boxes != null && labels!=null)
    {
      print("Received Data length: ");
      println(labels.size());
      
      
      for(int i=0;i<labels.size();++i)
      {
        String label=labels.getString(i);
        JSONArray box=boxes.getJSONArray(i);
        if(label.equals("person"))//change the label to your application
        {
          //send its data
          features[0]=box.getFloat(0);
          features[1]=box.getFloat(1);
          features[2]=box.getFloat(2);
          features[3]=box.getFloat(3);
          
          sendOSC();
        }
        
      }
    }
    
  }
}
