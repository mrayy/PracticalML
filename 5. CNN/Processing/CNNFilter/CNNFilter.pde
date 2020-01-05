/**
* PML: Apply convolution on an image (basic function of CNN) 
**/

//import your libraries

import gab.opencv.*;
import processing.video.*;
import java.awt.*;

import controlP5.*;

OpenCV opencv;
import oscP5.*;
import netP5.*;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.Mat;
import org.opencv.core.*;

PFont f;


boolean newImage=false;

//define your variables
Capture cam;

int CameraWidth=64;
int CameraHeight=48;

Mat kernel ;
Mat srcMat,dstMat;
int kernel_size=3;
int ind=0;
PImage img=null;

float[][] kernel_data=new float[kernel_size][kernel_size];

ControlP5 cp5;
Textfield[][] textInput=new Textfield[kernel_size][kernel_size];;

void setup() {
  System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
  size(640, 480);
  noStroke();
  smooth();
  
  img=createImage(CameraWidth, CameraHeight,ARGB);
   kernel =Mat.ones( kernel_size, kernel_size, CvType.CV_32F );
   srcMat=new Mat(CameraWidth,CameraHeight,CvType.CV_8UC3);
   dstMat=new Mat();
  printArray(Capture.list());
  f = createFont("Courier", 16);
  textFont(f);
  
  //run your code
  // The camera can be initialized directly using an 
  // element from the array returned by list():
  cam = new Capture(this, CameraWidth, CameraHeight,Capture.list()[0]);
  cam.start(); 
  
  opencv=new OpenCV(this,cam);
  opencv.useGray();
  
  cp5=new ControlP5(this);
  
  //write your kernel here
  kernel_data[0][0]=0;
  kernel_data[0][1]=-1;
  kernel_data[0][2]=0;
  
  kernel_data[1][0]=-1;
  kernel_data[1][1]=5;
  kernel_data[1][2]=-1;
  
  kernel_data[2][0]=0;
  kernel_data[2][1]=-1;
  kernel_data[2][2]=0;
  
  for(int i=0;i<kernel_size;++i)
  {
    for(int j=0;j<kernel_size;++j)
    {
      textInput[i][j]=cp5.addTextfield(str(i)+","+str(j))
              .setPosition(200+i*50,300+j*50)
              .setSize(50,30)
              .setText(str(kernel_data[i][j]))
              .setInputFilter(ControlP5.FLOAT);
    }
  }
  
  
}

void draw() {
  
  //check if camera has new image
  if (newImage) 
  {
    background(0);
    newImage=false;
    fill(255);
    
    
    opencv.loadImage(cam);
    
      
    float total=0;
    for(int i=0;i<kernel_size;++i)
    {
      for(int j=0;j<kernel_size;++j)
      {
        try{
          kernel_data[i][j]=Float.parseFloat(textInput[i][j].getText());
        }
        catch(Exception e)
        {
          kernel_data[i][j]=0;
        }
        total+=kernel_data[i][j];
      }
    }
    total=1.0/total;
    
    for(int i=0;i<kernel_size;++i)
    {
      for(int j=0;j<kernel_size;++j)
      {
        kernel.put(i,j,kernel_data[i][j]*total);
      }
    }
    Imgproc.filter2D(opencv.getGray(),dstMat,-1,kernel);
    opencv.toPImage(dstMat,img);
    
    image(opencv.getSnapshot(),0,0,width/2,240);
    image(img,width/2,0,width/2,240);
  
  }
}


void captureEvent(Capture c) {
  c.read();
  newImage=true;
}
