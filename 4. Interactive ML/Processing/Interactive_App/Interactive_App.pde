/**
* Simple example to capture web camera images, and send it to Wekinator
**/

import oscP5.*;
import netP5.*;

OscP5 oscP5;
PFont f;


void setup() {

  size(300, 200, P2D);
  noStroke();
  smooth();
  
  f = createFont("Courier", 30);
  textFont(f);
  
  /* start oscP5, listening for incoming messages at port 4200 */
  oscP5 = new OscP5(this,4200);
  
}

String label="";
int index;
void draw() {
    clear();
    background(255);
    fill(0, 0, 0);
    text(label, 25, 25 );
}



//This is called automatically when OSC message is received
void oscEvent(OscMessage theOscMessage) {
 if (theOscMessage.checkAddrPattern("/output/label")==true) {
     println(theOscMessage.typetag());
     if(theOscMessage.checkTypetag("is")) {
       index=theOscMessage.get(0).intValue();
        label=theOscMessage.get(1).stringValue();
       
     }
 }
 if (theOscMessage.checkAddrPattern("/output/done")==true) {
 }
}
