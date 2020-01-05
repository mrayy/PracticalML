

import processing.serial.*;


void setup() 
{
  size(200, 200);
  printArray(Serial.list());
  
  //check the name/index of the Serial device in the list
  int PortIndex=3;
  String portName = Serial.list()[PortIndex];
  println("Selecting Port["+PortIndex+"]: "+ portName);
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
    text(fromArduinoData[i],50,i*30+30);
  }
  delay(10);
}

//called when new data arrives
void ArduinoDataArrived()
{
}

void keyPressed()
{
  if(key=='1')
  {
    toArduinoData[0]=1;
    toArduinoData[1]=0;
    toArduinoData[2]=0;
  }
  if(key=='2')
  {
    toArduinoData[0]=0;
    toArduinoData[1]=1;
    toArduinoData[2]=0;
  }
  if(key=='3')
  {
    toArduinoData[0]=0;
    toArduinoData[1]=0;
    toArduinoData[2]=1;
  }
}

void keyReleased()
{
  if(key==' ')
  {
    toArduinoData[0]=0;
  }
}
