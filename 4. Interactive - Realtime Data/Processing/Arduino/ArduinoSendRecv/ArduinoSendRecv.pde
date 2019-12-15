

import processing.serial.*;

Serial myPort;  // Create object from Serial class
final int SENT_DATA= 6; //same as the one in arduino
float[] sensor_data=new float[SENT_DATA]; //sensor data from arduino

final int RECEIVED_DATA=3;//same as the one in arduino
float[] receivedData=new float[RECEIVED_DATA];//data to be sent to arduino (control code)


void setup() 
{
  size(200, 200);
  printArray(Serial.list());
  
  //check the name/index of the Serial device in the list
  String portName = Serial.list()[1];
  myPort = new Serial(this, portName, 9600);
}


void draw()
{
  
  ReadSerial();
  WriteSerial();
  
  
  background(255);             // Set background to white
  fill(0);
  for(int i=0;i<SENT_DATA;++i)
  {
    text(sensor_data[i],50,i*30+30);
  }
  delay(10);
}

//called when new data arrives
void ArduinoDataArrived()
{
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
