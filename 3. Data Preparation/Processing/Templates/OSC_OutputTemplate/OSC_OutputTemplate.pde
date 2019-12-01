
//Necessary for OSC communication with Wekinator:
import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress dest;

PFont f;

final int OutputCount=3;
float[] receivedValues=new float[OutputCount];

void setup()
{
  size(640, 480,P2D);
  noStroke();
  smooth();
  
  f = createFont("Courier", 16);
  textFont(f);
  
  //Initialize OSC communication
  oscP5 = new OscP5(this,12000); //listen for OSC messages on port 12000 (Wekinator default)
  dest = new NetAddress("127.0.0.1",6448); //send messages back to Wekinator on port 6448, localhost (this machine) (default)
  
   //Write here any initialization code you need
   
}



void draw()
{
  background(0);
  fill(255);
  stroke(255);
  
  
  text( "Listening for "+OutputCount+" values from /wek/outputs on port 12000", 5, 30 );
}

void OnNewValuesReceived(float[] values)
{
  //process the received output values from wekinator
}

//This is called automatically when OSC message is received
void oscEvent(OscMessage theOscMessage) {
 if (theOscMessage.checkAddrPattern("/wek/outputs")==true) {
 
     for(int i=0;i<OutputCount;++i)
     {
       receivedValues[i]=theOscMessage.get(i).floatValue();
     }
     
     OnNewValuesReceived(receivedValues);
   
      println("Received new params value from Wekinator"); 
 }
}
