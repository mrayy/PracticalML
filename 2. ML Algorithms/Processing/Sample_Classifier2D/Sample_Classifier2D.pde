
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress dest;
PFont f;

final int NB_Classes=3;
ArrayList<PVector>[] points=new ArrayList[NB_Classes];
int current_class=0;
 
color[] colors={color(255,0,0),color(0,255,0),color(0,0,255)};
 
PImage canvasImg;
int CanvasW=32;
int CanvasH=32;

boolean testInput=false;

void setupOSC()
{
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,4200);
  dest = new NetAddress("127.0.0.1",9000);
  canvasImg = createImage(CanvasW,CanvasH,RGB);  // Make an image holder object
  
}


void setup() {
  size(640, 640);
  background(102);
  
  for(int i=0;i<NB_Classes;i++)
    points[i]=new ArrayList<PVector>();
    
    
    setupOSC();
}

void draw() {
  background(255);
  
  image(canvasImg,0,0,width,height); 
  
  for(int c=0;c<NB_Classes;++c){
      fill(colors[c]);
      ArrayList<PVector> arr=(ArrayList<PVector>)points[c];
    for(int i=0;i<arr.size();++i){
      PVector v=arr.get(i);
      ellipse(v.x*width, v.y*height,10,10);
    }
  }
  
  if(testInput==false)
    fill(colors[current_class]);
  else
    fill(255);
  ellipse(mouseX, mouseY,5,5);
}


void mousePressed()
{
  if(testInput==false)
  {
    PVector v=new PVector(mouseX/(float)width,mouseY/(float)height);
    points[current_class].add(v);
    
    sendOscSample(v,current_class);
  }else
  {
    PVector v=new PVector(mouseX/(float)width,mouseY/(float)height);
    sendOscInput(v);
  }
}
void keyReleased()
{
  
  if(key==' ')
  {
    testInput=false;
  }
}
void keyPressed()
{
  if(key=='1')
    current_class=0;
    
  if(key=='2')
    current_class=1;
  if(key=='3')
    current_class=2;
   
  if(key==' ')
  {
    testInput=true;
  }
  if(key=='r')
  {
    
    for(int c=0;c<NB_Classes;++c){
      ArrayList<PVector> arr=(ArrayList<PVector>)points[c];
      for(int i=0;i<arr.size();++i){
           
          PVector v= arr.get(i);
          
          sendOscSample(v,c);
      }
    }
  }
  if(key=='c')
  {
    for(int c=0;c<NB_Classes;++c){
      points[c].clear();
    }
    canvasImg = createImage(CanvasW,CanvasH,RGB);  // Make an image holder object
    
  }
  
  if(key=='q')
  {
    OscMessage msg = new OscMessage("/quit");
    oscP5.send(msg, dest);
  }
}


void sendOscSample(PVector p,int c) {
  OscMessage msg = new OscMessage("/inputs/sample");
  
  msg.add(p.x);
  msg.add(p.y);
  msg.add(c);
  oscP5.send(msg, dest);
}
void sendOscInput(PVector p) {
  OscMessage msg = new OscMessage("/inputs/point");
  
  msg.add(p.x); 
  msg.add(p.y);
  oscP5.send(msg, dest);
}

//This is called automatically when OSC message is received
void oscEvent(OscMessage theOscMessage) {
 if (theOscMessage.checkAddrPattern("/result")==true) {
       // print(theOscMessage.typetag());
      //  print(" ");
     if(theOscMessage.checkTypetag("fffff")) { //Now looking for 5 parameters
        int X = (int)(theOscMessage.get(0).floatValue()*CanvasW); //get this parameter
        int Y = (int)(theOscMessage.get(1).floatValue()*CanvasH); //get 2nd parameter
        float A = theOscMessage.get(2).floatValue()*255; //get third parameters
        float B = theOscMessage.get(3).floatValue()*255; //get third parameters
        float C = theOscMessage.get(4).floatValue()*255; //get third parameters
        canvasImg.pixels[Y*CanvasW+X]=color(A,B,C);
        canvasImg.updatePixels();
      } else {
        
      }
 }
 if (theOscMessage.checkAddrPattern("/output/point")==true) {
       // print(theOscMessage.typetag());
      //  print(" ");
     if(theOscMessage.checkTypetag("ffi")) { //Now looking for 3 parameters
     
        float X = (theOscMessage.get(0).floatValue()); //get this parameter
        float Y = (theOscMessage.get(1).floatValue()); //get 2nd parameter
        int C = (int)theOscMessage.get(2).intValue(); //get third parameters
        
        PVector v=new PVector(X,Y);
        points[C].add(v);
        
     }
 }
}
