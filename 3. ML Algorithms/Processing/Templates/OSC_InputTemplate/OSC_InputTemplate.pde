/* Bare bone example in processing to communicate over OSC to send inputs */

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress dest;

PFont f;


final int FeaturesCount= 10; //set the number of features your program generates
float[] features=new float[FeaturesCount];


void setup() {
  f = createFont("Courier", 16);
  textFont(f);

  size(640, 480, P2D);
  noStroke();
  smooth();
  
  
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,9000);
  dest = new NetAddress("127.0.0.1",6448);
  
   
   //Write here any initialization code you need
  
}


void draw() {
  background(0);
  fill(255);
  stroke(255);
  
  //Any update or processing code here
  
  sendOSC();//optional to send here
  
  //Display some information
  text("Continuously sends **** ("+FeaturesCount+" inputs) to Wekinator\nUsing message /wek/inputs, to port 6448", 10, 30);
}

void sendOSC() {
  OscMessage msg = new OscMessage("/wek/inputs");
  
  for(int i=0;i<FeaturesCount;++i)
    msg.add((float)features[i]);
  oscP5.send(msg, dest);
}
