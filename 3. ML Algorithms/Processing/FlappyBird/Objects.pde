
class bird{
  float xPos,yPos,ySpeed;
  bird(){
    xPos = 250;
    yPos = 400;
  }
  void drawBird(){
    stroke(255);
    noFill();
    strokeWeight(2);
    ellipse(xPos,yPos,20,20);
  }
  void jump(){
   ySpeed=-10; 
  }
  void drag(){
   ySpeed+=0.4; 
  }
  void move(){
   yPos+=ySpeed; 
   for(int i = 0;i<3;i++){
    p[i].xPos-=3;
   }
  }
  void checkCollisions(){
     if(yPos>800){
      end=false;
     }
    for(int i = 0;i<3;i++){
      if((xPos<p[i].xPos+10&&xPos>p[i].xPos-10)&&(yPos<p[i].opening-100||yPos>p[i].opening+100)){
       end=false; 
      }
    }
  } 
}
class pillar{
  float xPos, opening;
  boolean cashed = false;
  pillar(int i){
    xPos = 100+(i*200);
    opening = random(600)+100;
 }
 void drawPillar(){
   line(xPos,0,xPos,opening-100);  
   line(xPos,opening+100,xPos,800);
 }
 void checkPosition(){
  if(xPos<0){
     xPos+=(200*3);
     opening = random(600)+100;
     cashed=false;
  } 
  if(xPos<250&&cashed==false){
   cashed=true;
   score++; 
  }
 }

}
