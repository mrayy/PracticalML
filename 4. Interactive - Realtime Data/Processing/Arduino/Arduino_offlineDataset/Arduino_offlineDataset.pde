

PFont f;

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
  
  
  printArray(Serial.list());
  
  //check the name/index of the Serial device in the list
  int PortIndex=3;
  String portName = Serial.list()[PortIndex];
  println("Selecting Port["+PortIndex+"]: "+ portName);
  myPort = new Serial(this, portName, 9600);
  
  
   //Write here any initialization code you need 
   NumberOfLabels=Labels.length;
   Dataset=new ArrayList[NumberOfLabels];//Create empty dataset to put samples inside
   for(int i=0;i<NumberOfLabels;++i)
   {
     Dataset[i]=new ArrayList();
   }
}

//called when new data arrives
void ArduinoDataArrived()
{
  receivedSample.value[0]=fromArduinoData[0];
  receivedSample.value[1]=fromArduinoData[1];
  receivedSample.value[2]=fromArduinoData[2];
  receivedSample.value[3]=fromArduinoData[3];
  receivedSample.value[4]=fromArduinoData[4];
  receivedSample.value[5]=fromArduinoData[5];
  
  AddSample();
}



void draw()
{
  background(0);
  fill(255);
  stroke(255);
  
  ReadSerial();
  WriteSerial();
  
  String valsStr=""; 
  //process the received output values from wekinator
  for(int i=0;i<receivedSample.value.length;++i)
  {
    valsStr+=receivedSample.value[i]+", ";
  }
  
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
