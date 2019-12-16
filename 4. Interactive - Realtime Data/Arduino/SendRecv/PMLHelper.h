
#define SENT_DATA 6 //3 for accel (X,Y,Z), and 3 for angles (pitch,yaw,roll)
float sensor_data[SENT_DATA];

#define RECEIVED_DATA 3
float receivedData[RECEIVED_DATA];


void DataReceived();
void ReadSensorData();

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

void UpdatePML()
{
  
  ProcessSerial(&Serial);//Check if any data arrived to serial port

  ReadSensorData();//process sensor data
  SendData(&Serial);      //send sensor data

}
