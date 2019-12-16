

//for this example, you will need to install MPU6050_tockn library

//Must Include this file!
#include "PMLHelper.h"

#include <MPU6050_tockn.h>
#include <Wire.h>


//define sensor variable
MPU6050 mpu6050(Wire);

void setup()
{
  Serial.begin(9600);

  //setup code depending on your application
  pinMode(13,OUTPUT);

  //setup MPU6050
  Wire.begin();
  mpu6050.begin();
  mpu6050.calcGyroOffsets(false,500,500);
}
void loop()
{

  UpdatePML();
  delay(50); //delay (depends on your application)
}
//call back function when new data arrive
void DataReceived()
{
  if(receivedData[0]==0)
  {
    digitalWrite(13,LOW); 
  }else{
    digitalWrite(13,HIGH); 
  }
}
//function to fill in sensor data. You can customize
void ReadSensorData()
{
  
  mpu6050.update();

  sensor_data[0]=mpu6050.getAccX();
  sensor_data[1]=mpu6050.getAccY();
  sensor_data[2]=mpu6050.getAccZ();
  sensor_data[3]=mpu6050.getAngleX();
  sensor_data[4]=mpu6050.getAngleY();
  sensor_data[5]=mpu6050.getAngleZ();
}
