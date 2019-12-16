
import processing.serial.*;

final int SENT_DATA= 6; //same as the one in arduino
float[] fromArduinoData=new float[SENT_DATA]; //sensor data from arduino

final int RECEIVED_DATA=3;//same as the one in arduino
float[] toArduinoData=new float[RECEIVED_DATA];//data to be sent to arduino (control code)


char[] serialbuffer=new char[256];
boolean serialStarted=false;
int bufferIndex=0;

Serial myPort;  // Create object from Serial class


void WriteSerial()
{
  myPort.write("@");//start character
  for(int i=0;i<RECEIVED_DATA;i++)
  {
    myPort.write(str(toArduinoData[i]));//4 floating points precision
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
          fromArduinoData[i]=float(data[i]);
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
