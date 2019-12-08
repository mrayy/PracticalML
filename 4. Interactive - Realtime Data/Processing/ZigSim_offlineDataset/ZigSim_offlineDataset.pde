
//Necessary for OSC communication with Wekinator:
import oscP5.*;
import netP5.*;


OscP5 oscP5;
NetAddress dest;

PFont f;

String DeviceUUID="Yamen";// Change this according to your device name in ZIGSim

final int FeaturesCount=6;
class Sample
{
  public float[] value=new float[FeaturesCount];
}

//define the labels
int NumberOfLabels;
String[] Labels=new String[]{"Idle", "Walk", "Run", "jogging"};
int currentLabel=0;
boolean isRecording;

Sample receivedSample=new Sample();
ArrayList<Sample>[] Dataset;


void setup()
{
  size(1024, 200);
  noStroke();
  smooth();
  
  f = createFont("Courier", 16);
  textFont(f);
  
  //Initialize OSC communication
  oscP5 = new OscP5(this,50001); //listen for OSC messages on port 50001 (ZIGSim default)
  
   //Write here any initialization code you need 
   NumberOfLabels=Labels.length;
   Dataset=new ArrayList[NumberOfLabels];//Create empty dataset to put samples inside
   for(int i=0;i<NumberOfLabels;++i)
   {
     Dataset[i]=new ArrayList();
   }
}



void draw()
{
  background(0);
  fill(255);
  stroke(255);
  
  
  String valsStr=""; 
  //process the received output values from wekinator
  for(int i=0;i<receivedSample.value.length;++i)
  {
    valsStr+=receivedSample.value[i]+", ";
  }
  
  text("Set ZIGSim Device UUID to: " + DeviceUUID, 10, 30); 
  text("Current Label ID: "+Labels[currentLabel]+ " - Samples Count: " + +Dataset[currentLabel].size(), 10, 60);
  if(isRecording)
    text("Recording", 10, 90);
  else
    text("Stopped", 10,90);
  text(valsStr, 10, 120);
}

void keyPressed()
{
  if(key==' ')
  {
    if(isRecording==false)
      isRecording=true;
    else 
      isRecording=false;
  }
  if(key=='1')
  {
    currentLabel=0;
  }
  if(key=='2')
  {
    currentLabel=1;
  }
  if(key=='3')
  {
    currentLabel=2;
  }
  if(key=='4')
  {
    currentLabel=3;
  }
  if(key=='5')
  {
    currentLabel=4;
  }
  if(key=='6')
  {
    currentLabel=4;
  }
  if(key=='7')
  {
    currentLabel=6;
  }
  if(key=='8')
  {
    currentLabel=7;
  }
  if(key=='9')
  {
    currentLabel=8;
  }
  if(currentLabel>=NumberOfLabels)
  {
    currentLabel=NumberOfLabels-1;
  }
  
  if(key=='s')
  {
    SaveData();
  }
}


void SaveData()
{
  Table table;
  String[] labelsIDs=new String[NumberOfLabels];
  
  //iterate over the labels
  for(int i=0;i<NumberOfLabels;i++)
  {
    table=new Table();
     for(int v=0;v<FeaturesCount;v++)
     {
       table.addColumn("C"+v);//add temporary column names
     }
    
    //iterate over samples per label
    for(int j=0;j<Dataset[i].size();j++)
    {
       Sample sample= Dataset[i].get(j);//get the sample
       TableRow row=table.addRow();
         
       //add samples values to the table
       for(int v=0;v<FeaturesCount;v++)
       {
         row.setFloat("C"+v, sample.value[v]);
       }
    }
    saveTable(table, "data/"+Labels[i]+".csv");
    labelsIDs[i]=(i+1)+", "+Labels[i];
  }
  
  saveStrings("data/labels.txt",labelsIDs);
}

void AddSample() {
  if(isRecording==false)
    return;
    //copy the received sample
  Sample newSample=new Sample();
  for(int i=0;i<FeaturesCount;++i)
    newSample.value[i]=receivedSample.value[i];
    
  Dataset[currentLabel].add(newSample);
}

//This is called automatically when OSC message is received
void oscEvent(OscMessage theOscMessage) {
 if (theOscMessage.checkAddrPattern("/ZIGSIM/"+DeviceUUID+"/accel")==true) {
       receivedSample.value[0]=theOscMessage.get(0).floatValue();
       receivedSample.value[1]=theOscMessage.get(1).floatValue();
       receivedSample.value[2]=theOscMessage.get(2).floatValue();
 }else if (theOscMessage.checkAddrPattern("/ZIGSIM/"+DeviceUUID+"/gyro")==true) {
       receivedSample.value[3]=theOscMessage.get(0).floatValue();
       receivedSample.value[4]=theOscMessage.get(1).floatValue();
       receivedSample.value[5]=theOscMessage.get(2).floatValue();
 }/*else if (theOscMessage.checkAddrPattern("/ZIGSIM/"+DeviceUUID+"/miclevel")==true) {
       receivedValues[6]=theOscMessage.get(0).floatValue();
       receivedValues[7]=theOscMessage.get(1).floatValue();
 }*/
 
 
 //special message to indicate the data for this sample are done
 if (theOscMessage.checkAddrPattern("/ZIGSIM/"+DeviceUUID+"/deviceinfo")==true) {
   AddSample();
 }
}
