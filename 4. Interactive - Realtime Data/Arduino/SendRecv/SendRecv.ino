#include "PMLHelper.h"


void setup()
{
  Serial.begin(9600);

  //setup code depending on your application
  pinMode(8,OUTPUT);
  pinMode(9,OUTPUT);
  pinMode(10,OUTPUT);
}
void loop()
{
  ProcessSerial(&Serial);//Check if any data arrived to serial port

  ReadSensorData();//process sensor data
  SendData(&Serial);      //send sensor data
  
  delay(50); //delay (depends on your application)
}
//call back function when new data arrive
void DataReceived()
{
  if(receivedData[0]==0)
  {
    digitalWrite(8,LOW); 
  }else{
    digitalWrite(8,HIGH); 
  }
  
  if(receivedData[1]==0)
  {
    digitalWrite(9,LOW); 
  }else{
    digitalWrite(9,HIGH); 
  }
  
  if(receivedData[2]==0)
  {
    digitalWrite(10,LOW); 
  }else{
    digitalWrite(10,HIGH); 
  }
  
}
//function to fill in sensor data. You can customize
void ReadSensorData()
{
  
  sensor_data[0]=analogRead(A0);
  sensor_data[1]=analogRead(A1);
  sensor_data[2]=analogRead(A2);
  sensor_data[3]=analogRead(A3);
  sensor_data[4]=analogRead(A4);
  sensor_data[5]=analogRead(A5);
}
