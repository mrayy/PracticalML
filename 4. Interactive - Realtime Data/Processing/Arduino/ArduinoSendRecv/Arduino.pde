
char[] serialbuffer=new char[256];
boolean serialStarted=false;
int bufferIndex=0;

void WriteSerial()
{
  myPort.write("@");//start character
  for(int i=0;i<RECEIVED_DATA;i++)
  {
    myPort.write(str(receivedData[i]));//4 floating points precision
    if(i!=RECEIVED_DATA-1)  //Comma seperated data
      myPort.write(",");
  }
  myPort.write("#");//end character
}

//Helper function to read arduino data
void ReadSerial()
{
  while ( myPort.available() > 0) {  // If data is available,
    
    char c=(char)myPort.read();         // read it and store it in val
    //print(c);
    if(c=='@')
    {
      serialStarted=true;
      bufferIndex=0;
    }else
    if(c=='#')
    {
      serialStarted=false;//finished the data line
      serialbuffer[bufferIndex]='\0';//character for end of string
      String[] data=split(new String(serialbuffer),',');
      if(data.length==SENT_DATA)//make sure its the same length
      {
        for(int i=0;i<SENT_DATA;i++)
        {
          sensor_data[i]=float(data[i]);
        } 
        ArduinoDataArrived();
      }
      
    }else //normal character arrived, check if we ready to receive it
    if(serialStarted)
    {
      serialbuffer[bufferIndex]=c;
      bufferIndex=bufferIndex+1;
    }
    
  }
}
