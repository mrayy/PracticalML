


import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress dest;

Serial myPort;  // Create object from Serial class
final int SENT_DATA= 6; //same as the one in arduino
float[] sensor_data=new float[SENT_DATA]; //sensor data from arduino

final int RECEIVED_DATA=3;//same as the one in arduino
float[] receivedData=new float[RECEIVED_DATA];//data to be sent to arduino (control code)


final int TimeSeries=10; //time series samples
final int SensorsCount=2;
final int FeaturesCount= SensorsCount*TimeSeries; //set the number of features your program generates
float[] features=new float[FeaturesCount];


void setup() 
{
  size(640, 480);
  noStroke();
  smooth();
  
  printArray(Serial.list());
  //check the name/index of the Serial device in the list
  String portName = Serial.list()[1];
  myPort = new Serial(this, portName, 9600);
  
  
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,0);
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

  for(int i=0;i<TimeSeries;++i)
  {
    for(int j=0;j<SensorsCount;++j)
    {
      text(features[i*SensorsCount+j],100+j*100,i*20+80);
    }
  }
  delay(10);
  
}
//called when new data arrives
void ArduinoDataArrived()
{
  //shift all samples one step
  for(int i=TimeSeries-1;i>0;--i)
  {
    for (int j=0;j<SensorsCount;++j)
    {
      features[i*SensorsCount+j]=features[(i-1)*SensorsCount+j];
    }
  }
  
  //only use two features
  for (int j=0;j<SensorsCount;++j)
  {
    features[j]=sensor_data[j];
  }
  
  sendOSC();//optional to send here
  
}

void keyPressed()
{
  if(key==' ')
  {
    receivedData[0]=1;
  }
}

void keyReleased()
{
  if(key==' ')
  {
    receivedData[0]=0;
  }
}

void sendOSC() {
  OscMessage msg = new OscMessage("/wek/inputs");
  
  for(int i=0;i<FeaturesCount;++i)
    msg.add((float)features[i]);
  oscP5.send(msg, dest);
}
