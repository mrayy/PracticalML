


import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress dest;

//To Wekinator
final int FeaturesCount= 1; //set the number of features your program generates
float[] features=new float[FeaturesCount];

final int OutputCount=1;
float[] receivedValues=new float[OutputCount];

void setup() 
{
  size(640, 480);
  noStroke();
  smooth();
  
  printArray(Serial.list());
  
  //check the name/index of the Serial device in the list
  int PortIndex=3;
  String portName = Serial.list()[PortIndex];
  println("Selecting Port["+PortIndex+"]: "+ portName);
  myPort = new Serial(this, portName, 9600);
  
  
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,12000);
  dest = new NetAddress("127.0.0.1",6448);
}


void draw()
{
  
  ReadSerial();
  WriteSerial();
  
  
  background(255);             // Set background to white
  fill(0);
   //Display some information
  text("Continuously sends **** ("+FeaturesCount+" inputs) to Wekinator\nUsing message /wek/inputs, to port 6448", 10, 30);

  for(int i=0;i<SENT_DATA;++i)
  {
    text(fromArduinoData[i],100,i*30+120);
  }
  delay(10);
  
}
//called when new data arrives
void ArduinoDataArrived()
{
  //only use two features
  features[0]=fromArduinoData[0];
  
  sendOSC();//optional to send here
  
}


void sendOSC() {
  OscMessage msg = new OscMessage("/wek/inputs");
  
  for(int i=0;i<FeaturesCount;++i)
    msg.add((float)features[i]);
  oscP5.send(msg, dest);
}

void OnNewValuesReceived(float[] values)
{
  //process the received output values from wekinator
  println(values[0]);
  if(int(values[0])==1)
  {
    toArduinoData[0]=1;
    toArduinoData[1]=0;
    toArduinoData[2]=0;
  }
  if(int(values[0])==2)
  {
    toArduinoData[0]=0;
    toArduinoData[1]=1;
    toArduinoData[2]=0;
  }
  if(int(values[0])==3)
  {
    toArduinoData[0]=0;
    toArduinoData[1]=0;
    toArduinoData[2]=1;
  }
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
