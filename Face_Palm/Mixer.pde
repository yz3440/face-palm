class Mixer {
  FaceCam fc;
  HandCam hc;
  PVector offset;
  PImage begin1;
  PImage begin2;
  PGraphics pg;
  boolean hasHand;

  Mixer(FaceCam fc_, HandCam hc_) {
    this.fc = fc_;
    this.hc = hc_;
    offset = new PVector(0, 0);
    //pg = createGraphics(width, height);
    begin1 = loadImage("begin.jpg");
    begin2 = loadImage("begin2.jpg");
    hasHand = false;
  }

  void updateGraphics() {
    PImage faceImg = fc.getFace();
    ArrayList <Hand> hands = hc.getHands();
    //pg.beginDraw();
    //pg.background(0);
    if (hands.size() > 0) {
      hasHand = true;
      while (hands.size()>0) {
        Hand h = hands.remove(0);
        PImage handImg = h.getImg();
        int x = h.getPosX();
        int y = h.getPosY();
        int size = h.getSize();
        PImage tempFace = createImage(size, size, RGB);
        tempFace.copy(faceImg, 0, 0, faceImg.width, faceImg.height, 
          0, 0, tempFace.width, tempFace.height);

        //println(handImg.width, tempFace.width);
        //image(tempFace,0,0);

        //pushStyle();
        //colorMode(HSB);
        //tint(map(x, 0, width, 0, 255), 255.0, map(x,0,width,0,255),map(size,100,500,0,255));
        //colorMode(RGB);
        //popStyle();

        int off = abs(x-width/2) + abs(y-height/2);
        if(off > 200) off = int((off-200) / 70) + 1;
        else off = 1;
        tempFace = splitFace(tempFace, off);

        tempFace.mask(handImg);

        x = h.getPosX()-h.getSize()/2;
        y = h.getPosY()-h.getSize()/2;
        image(tempFace, x + offset.x, y + offset.y);
        //imageFlipped(tempFace, x + offset.x, y + offset.y);
        //image(handImg, h.getPosX()-h.getSize()/2, h.getPosY()-h.getSize()/2);
      }
    } else {
      hasHand = false;
      if (frameCount % 30 < 15) image(begin1, 0, 0);
      else image(begin2, 0, 0);
    }
    //pg.endDraw();
  }

  PImage getGraphics() {
    PImage result;
    if (hasHand) result = pg;
    else if (frameCount%50 < 25)result = begin1;
    else result = begin2;
    return result;
  }

  void addToOffset(PVector v) {
    this.offset.add(v);
  }

  PImage splitFace(PImage img, int num) {
    PImage result = createImage(img.width, img.height, RGB);
    int splitSize = int(img.width / num);
    for (int i = 0; i < num; i++) {
      for (int j = 0; j < num; j++) {
        int x = i * splitSize;
        int y = j * splitSize;
        result.copy(img, 0, 0, img.width, img.height, x, y, splitSize, splitSize);
      }
    }
    return result;
  }
  void imageFlipped( PImage img, float x, float y ) {
    pushMatrix(); 
    scale( 1, -1 );
    image( img, x, - y - img.height ); 
    popMatrix();
  }
}
