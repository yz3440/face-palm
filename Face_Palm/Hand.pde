class Hand {
  PImage handImg;
  PVector handPos;
  PVector posOffset;
  int size;
  
  Hand(PImage img, PVector pos) {
    this.handImg = img;
    this.handPos = pos;
    this.size = img.width;
  }
  

  PImage getImg() {
    return this.handImg;
  }
  
  PImage applyVFX(){
    PImage result = this.handImg.copy();
    
    
    return result;
  
  }
  
  int getPosX() {
    return (int)this.handPos.x;
  }
  int getPosY() {
    return (int)this.handPos.y;
  }
  PVector getPos() {
    return this.handPos;
  }
  int getSize() {
    return this.size;
  }

  void display() {
    image(this.handImg, this.handPos.x - size/2, this.handPos.y - size/2);
  }
}
