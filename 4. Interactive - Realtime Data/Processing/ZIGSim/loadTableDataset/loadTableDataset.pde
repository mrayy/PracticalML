
//Necessary for OSC communication with Wekinator:
import oscP5.*;
import netP5.*;


OscP5 oscP5;
NetAddress dest,wekControlDest;

PFont f;



Table table;

class Sample
{
  public float[] values;
}
int FeaturesCount=0;
int NumberOfLabels;
String[] Labels;
ArrayList<Sample>[] Dataset;

void setup() {
  size(1024, 200);
  noStroke();
  smooth();
  
  f = createFont("Courier", 16);
  textFont(f);
  
  //Initialize OSC communication
  oscP5 = new OscP5(this,50001); //listen for OSC messages on port 50001 (ZIGSim default)
  dest = new NetAddress("127.0.0.1",6448); //send messages back to Wekinator on port 6448, localhost (this machine) (default)
  wekControlDest = new NetAddress("127.0.0.1",6448); //send messages back to Wekinator on port 6448, localhost (this machine) (default)
  
  loadData("data/labels.txt");
}

void draw() {
  background(0);
  fill(255);
  stroke(255);
  
  text("Press space to send an input count of "+FeaturesCount+" INPUTS to Wekinator, to port 6448", 10, 30);
  text("Set classes count to a total of "+ NumberOfLabels+" LABELS",10,60);
}

void keyPressed()
{
  if(key==' ')
  {
    sendData();
  }
}

void loadData(String samplesPath) {
  String[] labelsIDs=loadStrings(samplesPath);
  NumberOfLabels=labelsIDs.length;
  Dataset=new ArrayList[NumberOfLabels];
  Labels=new String[NumberOfLabels];
  
  for(int i=0;i<labelsIDs.length;++i)
  {
    String[] parts=split(labelsIDs[i],", ");
    int ID=int(parts[0]);//get the ID part
    Labels[i]=parts[1];//get the label part
    
    Dataset[i]=new ArrayList(); 
    
    String tablePath="data/"+Labels[i]+".csv";
    Table table=loadTable(tablePath);
    if(FeaturesCount==0)
        FeaturesCount=table.getColumnCount();
    //iterate over the samples
    for(int j=1;j<table.getRowCount();j++)
    {
      TableRow row=table.getRow(j);//get the row
      Sample newSample=new Sample();
      newSample.values=new float[FeaturesCount];
      for(int v=0;v<FeaturesCount;v++)
      {
        newSample.values[v]=row.getFloat(v);
      }
      Dataset[i].add(newSample);
    }
    
    println("Loaded Label: "+ Labels[i] + " with total number of "+Dataset[i].size() + " Samples");
  }
}

void sendData()
{
  OscMessage msg;
  float[] outputs=new float[NumberOfLabels];
  for(int i=0;i<NumberOfLabels;i++)
  outputs[i]=0;

  //start recording
  msg = new OscMessage("/wekinator/control/startRecording");
  oscP5.send(msg, wekControlDest);
  
  for(int i=0;i<NumberOfLabels;++i)
  {
    outputs[i]=1;
      
    //set Wekinator outputs value
    msg = new OscMessage("/wekinator/control/outputs");
    //for(int j=0;j<NumberOfLabels;++j)
    //  msg.add(outputs[j]);
    msg.add(float(i+1));
    oscP5.send(msg, wekControlDest);
    
    for(int j=0;j<Dataset[i].size();j++)
    {
      Sample sample=Dataset[i].get(j);//get sample
      
      //build new input message to wekinator
      msg = new OscMessage("/wek/inputs");
      for(int v=0;v<FeaturesCount;++v)
        msg.add(sample.values[v]);
      oscP5.send(msg, dest);
      delay(10);
    }
    
    outputs[i]=0;
  }
  //stop recording
  msg = new OscMessage("/wekinator/control/stopRecording");
  oscP5.send(msg, wekControlDest);
}
