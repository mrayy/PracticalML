/**
* PML: process audio input using Fast Fourier Transformation (FFT), then send it using OSC to wekinator
**/
import oscP5.*;
import netP5.*;
  
import processing.sound.*;

OscP5 oscP5;
NetAddress dest;

PFont f;

FFT fft;
AudioIn in;
int bands = 64;
float[] spectrum = new float[bands];


final int FeaturesCount= bands; //set the number of features your program generates
float[] features=new float[FeaturesCount];


void setup() {
  f = createFont("Courier", 16);
  textFont(f);

  size(640, 480, P2D);
  noStroke();
  smooth();
  
  
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,9000);
  dest = new NetAddress("127.0.0.1",6448);
  
  //Write here any initialization code you need
  fft = new FFT(this, bands);
  in = new AudioIn(this, 0);
  
  // start the Audio Input
  in.start();
  
  // patch the AudioIn
  fft.input(in);
}


void draw() {
  background(0);
  fill(255);
  stroke(255);
  
  //Any update or processing code here
   fft.analyze(spectrum);
   
  for(int i = 0; i < bands; i++){
    // The result of the FFT is normalized
    // draw the line for frequency band i scaling it up by 5 to get more amplitude.
    ellipse( i*5, height/2, 10, spectrum[i]*height);
  } 
  for(int i=0;i<FeaturesCount;++i)
    features[i]=spectrum[i];
  sendOSC();//optional to send here
  
  //Display some information
  text("Continuously sends audio FFT bands ("+FeaturesCount+" inputs) to Wekinator\nUsing message /wek/inputs, to port 6448", 10, 30);
}

void sendOSC() {
  OscMessage msg = new OscMessage("/wek/inputs");
  
  for(int i=0;i<FeaturesCount;++i)
    msg.add((float)features[i]);
  oscP5.send(msg, dest);
}
