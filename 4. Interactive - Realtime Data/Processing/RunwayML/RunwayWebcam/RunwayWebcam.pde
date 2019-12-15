
// Example how to send image to Runway ML


import oscP5.*;
// import Runway library
import com.runwayml.*;
// reference to runway instance
RunwayOSC runway;

JSONObject data;// data received from Runway


void setup() {
  // match sketch size to default model camera setup
  size(600, 400);


  // setup Runway
  runway = new RunwayOSC(this);

  setupRMLImage();
}

void draw() {
  background(0);

  sendFrameToRunway();
  // draw sent image
  if (RMLImage!=null) {
    image(RMLImage, 0, 0, width, height);
  }
}



// this is called when new Runway data is available
void runwayDataEvent(JSONObject runwayData) {
  // point the sketch data to the Runway incoming data 
  data = runwayData;

  if (data!=null)//check if there is data
  {
    //do what you like with the data here (query for features, etc)
  }
}
