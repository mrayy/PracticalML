

#define SENT_DATA 6
float sensor_data[SENT_DATA];

#define RECEIVED_DATA 3
float receivedData[RECEIVED_DATA];

void setup()
{
  Serial.begin(9600);

  //setup code depending on your application
  pinMode(13,OUTPUT);
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
  
  sensor_data[0]=analogRead(A0);
  sensor_data[1]=analogRead(A1);
  sensor_data[2]=analogRead(A2);
  sensor_data[3]=analogRead(A3);
  sensor_data[4]=analogRead(A4);
  sensor_data[5]=analogRead(A5);
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
