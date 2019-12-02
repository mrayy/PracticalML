 //Flappy Code
 //original code from: https://forum.processing.org/two/discussion/3580/flappy-code
 
//Necessary for OSC communication with Wekinator:
import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress dest;


final int OutputCount=1;
float[] receivedValues=new float[OutputCount];


bird b = new bird();
pillar[] p = new pillar[3];
boolean end=false;
boolean intro=true;
int score=0;
void setup(){
  size(500,800);
  frameRate(30);
  
  //Initialize OSC communication
  oscP5 = new OscP5(this,12000); //listen for OSC messages on port 12000 (Wekinator default)
  dest = new NetAddress("127.0.0.1",6448); //send messages back to Wekinator on port 6448, localhost (this machine) (default)
  
  
  for(int i = 0;i<3;i++){
    p[i]=new pillar(i);
  }
}


int jumptimer=0;
void draw(){
  background(0);
  jumptimer=jumptimer+1;
  if(end){
    b.move();
    b.drag();
  }
  b.drawBird();
  b.checkCollisions();
  for(int i = 0;i<3;i++){
    p[i].drawPillar();
    p[i].checkPosition();
  }
  fill(0);
  stroke(255);
  textSize(32);
  if(end){
    rect(20,20,100,50);
    fill(255);
    text(score,30,58);
  }else{
    rect(150,100,200,50);
    rect(150,200,200,50);
    fill(255);
    if(intro){
      text("Flappy Code",155,140);
      text("Click to Play",155,240);
    }else{
      text("game over",170,140);
      text("score",180,240);
      text(score,280,240);
    }
  }
}
void reset(){
 end=true;
 score=0;
 b.yPos=400;
 for(int i = 0;i<3;i++){
  p[i].xPos+=550;
  p[i].cashed = false;
 }
}
void Jump(){
  
if(jumptimer<10)
  return;
  jumptimer=0;
 b.jump();
 intro=false;
 if(end==false){
   reset();
 }
}

void OnNewValuesReceived(float[] values)
{
  //process the received output values from wekinator
  if(values[0]>0.7)
    Jump();
}

//This is called automatically when OSC message is received
void oscEvent(OscMessage theOscMessage) {
 if (theOscMessage.checkAddrPattern("/wek/outputs")==true) {
 
     for(int i=0;i<OutputCount;++i)
     {
       receivedValues[i]=theOscMessage.get(i).floatValue();
     }
     
     OnNewValuesReceived(receivedValues);
   
      println("Received new params value from Wekinator"); 
 }
}
