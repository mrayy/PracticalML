
//Necessary for OSC communication with Wekinator:
import oscP5.*;
import netP5.*;
import java.net.InetAddress;

InetAddress inet;
String myIP;

OscP5 oscP5;
NetAddress dest;

PFont f;

final int FeaturesCount=6;
float[] receivedValues=new float[FeaturesCount];

String DeviceUUID="Yamen";

void setup()
{
  size(1024, 200);
  noStroke();
  smooth();
  
  f = createFont("Courier", 16);
  textFont(f);
  
  //Initialize OSC communication
  oscP5 = new OscP5(this,50001); //listen for OSC messages on port 50001 (ZIGSim default)
  dest = new NetAddress("127.0.0.1",6448); //send messages back to Wekinator on port 6448, localhost (this machine) (default)
  
   //Write here any initialization code you need
}



void draw()
{
  background(0);
  fill(255);
  stroke(255);
  
  
  String valsStr=""; 
  //process the received output values from wekinator
  for(int i=0;i<receivedValues.length;++i)
  {
    valsStr+=receivedValues[i]+", ";
  }
  text("Set ZIGSim Device UUID to: " + DeviceUUID, 10, 30); 
  text("Sending ZIGSim features ("+FeaturesCount+" inputs) to Wekinator using message /wek/inputs, to port 6448", 10, 60);
  text(valsStr, 10, 90);
}

void sendOSC() {
  OscMessage msg = new OscMessage("/wek/inputs");
  
  for(int i=0;i<FeaturesCount;++i)
    msg.add((float)receivedValues[i]);
  oscP5.send(msg, dest);
}

//This is called automatically when OSC message is received
void oscEvent(OscMessage theOscMessage) {
 if (theOscMessage.checkAddrPattern("/ZIGSIM/"+DeviceUUID+"/accel")==true) {
       receivedValues[0]=theOscMessage.get(0).floatValue();
       receivedValues[1]=theOscMessage.get(1).floatValue();
       receivedValues[2]=theOscMessage.get(2).floatValue();
 }else if (theOscMessage.checkAddrPattern("/ZIGSIM/"+DeviceUUID+"/gyro")==true) {
       receivedValues[3]=theOscMessage.get(0).floatValue();
       receivedValues[4]=theOscMessage.get(1).floatValue();
       receivedValues[5]=theOscMessage.get(2).floatValue();
 }/*else if (theOscMessage.checkAddrPattern("/ZIGSIM/"+deviceId+"/miclevel")==true) {
       receivedValues[6]=theOscMessage.get(0).floatValue();
       receivedValues[7]=theOscMessage.get(1).floatValue();
 }*/else
 if (theOscMessage.checkAddrPattern("/ZIGSIM/"+DeviceUUID+"/deviceinfo")==true) {
   sendOSC();
 }
}
