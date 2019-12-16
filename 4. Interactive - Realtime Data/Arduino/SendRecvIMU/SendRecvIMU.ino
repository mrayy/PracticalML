

//for this example, you will need to install MPU6050_tockn library

#include <MPU6050_tockn.h>
#include <Wire.h>


#define SENT_DATA 6 //3 for accel (X,Y,Z), and 3 for angles (pitch,yaw,roll)
float sensor_data[SENT_DATA];

#define RECEIVED_DATA 3
float receivedData[RECEIVED_DATA];


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

//Helper function to send data to the application
void SendData(Stream *s)
{
  //Start with a special character
  s->print("@");
  for(int i=0;i<SENT_DATA;i++)
  {
    s->print(sensor_data[i],4);//4 floating points precision
    if(i!=SENT_DATA-1)  //Comma seperated data
      s->print(",");
  }
  //Finish with another special character
  s->println("#");
}

//Helper function to receive data from the application
void ProcessSerial(Stream *s)
{
  char inputBuffer[64];
  int inputBufferIndex = 0;
  
  char* inputvalues[10];
  while (s->available() > 0)
  {
    char c = s->read();
    if (c == '@')
    {
      inputBufferIndex = 0;
    } else if (c == '#')
    {
      inputBuffer[inputBufferIndex] = 0;
      char *p = inputBuffer;
      char *str;
      int NParams= 0;
      while ((str = strtok_r(p, ",", &p)) != NULL) // delimiter is the semicolon
        inputvalues[NParams++] = str;

      if(NParams==RECEIVED_DATA)
      {
        for(int i=0;i<RECEIVED_DATA;++i)
        {
          receivedData[i] = atof(inputvalues[i]);
        } 
        DataReceived();
      }
    } else
    {
      inputBuffer[inputBufferIndex++] = c;
    }
  }
}
