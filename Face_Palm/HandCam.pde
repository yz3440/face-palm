class HandCam {
  Capture cam;
  OpenCV opencv;
  ImageWarper warper;
  ArrayList <Contour> contours;

  int numPixels;
  int numPixelsSmall;
  int contourThreshold;
  int scale;
  PImage diffRef;
  PImage diffImg;
  PImage warped;

  int diffThreshold;

  boolean flip;

  ArrayList <Hand> hands;

  HandCam(PApplet sketchRef, int cvScale, int threshold, int area, boolean flip) {
    this.cam = new Capture(sketchRef, 1920, 1080, extCam, 30);
    this.cam.start();

    this.opencv = new OpenCV(sketchRef, this.cam.width/cvScale, this.cam.height/cvScale);
    this.contourThreshold = area;

    this.warper = new ImageWarper(sketchRef, this.cam);

    this.scale = cvScale;
    this.diffThreshold = threshold;
    this.diffRef = cam.copy();
    this.diffImg = createImage(this.cam.width/this.scale, this.cam.height/this.scale, RGB);
    this.warped = createImage(1920, 1080, RGB);
    this.flip = flip;

    this.numPixels = cam.width*cam.height;
    this.numPixelsSmall = this.numPixels /this.scale/this.scale;

    this.hands = new ArrayList();
  }

  ArrayList <Hand> getHands() {
    return this.hands;
  }

  void updateWarped() {
    //this.warped = this.cam.copy();
    this.warped = warper.warp(this.cam);
  }

  void updateDiffImg() {
    this.warped.loadPixels();
    this.diffRef.loadPixels();
    this.diffImg.loadPixels();

    for (int y = 0; y < this.diffImg.height; y++) {
      for (int x = 0; x < this.diffImg.width; x++) {
        int index = y * this.diffImg.width + x;
        int indexScaled = y * this.scale * this.diffRef.width + x * this.scale;
        color currColor = this.warped.pixels[indexScaled];
        color prevColor = this.diffRef.pixels[indexScaled];
        int[] diffRGB = getDiffRGB(currColor, prevColor);
        int diffSum = diffRGB[0] + diffRGB[1] + diffRGB[2];

        if (this.flip) index = numPixelsSmall - index - 1;

        if (diffSum > diffThreshold && brightness(currColor) > 100) diffImg.pixels[index] = color(255);
        else diffImg.pixels[index] = color(0);
      }
    }
    this.diffImg.updatePixels();
  }

  void updateCVContours(boolean display) {
    opencv.loadImage(this.diffImg);
    opencv.gray();
    opencv.dilate();
    opencv.erode();
    opencv.erode();
    opencv.erode();
    opencv.erode();
    opencv.dilate();
    contours = opencv.findContours();

    for (Contour c : contours) {
      if (c.area()>this.contourThreshold) {
        strokeWeight(4);
        stroke(255, 0, 0);
        int minX = width;
        int maxX = 0;
        int minY = height;
        int maxY = 0;
        for ( PVector point : c.getPoints()) {
          int x = (int)point.x;
          int y = (int)point.y;
          if (display) point(x, y);
          if (x < minX) minX = x;
          if (x > maxX) maxX = x;
          if (y < minY) minY = y;
          if (y > maxY) maxY = y;
        }
        int side;
        int sideY = int((maxY-minY) * 1.0);
        int sideX = int((maxX-minX) * 1.0);
        if(sideX > sideY){
          side = sideX;
          maxY = minY + side;
        }else{
          side = sideY;
          maxX = minX + side;
        }
        //minX -= side/6;
        //maxX += side/6;
        
        
       

        if (side > 100) {
          PImage handImg = createImage(side * scale, side * scale, RGB);
          handImg.copy(this.diffImg, minX, minY, side, side, 0, 0, (int)(side * scale * 0.95), (int)(side * scale * 0.95));
          Hand h = new Hand(handImg, new PVector(maxX - side/2, maxY - side/2).mult(this.scale));
          hands.add(h);
        }
      }
    }
  }



  int[] getDiffRGB(color currColor, color prevColor) {
    int[] result = new int[3];

    int currR = (currColor >> 16) & 0xFF; // Like red(), but faster
    int currG = (currColor >> 8) & 0xFF;
    int currB = currColor & 0xFF;
    // Extract red, green, and blue components from previous pixel
    int prevR = (prevColor >> 16) & 0xFF;
    int prevG = (prevColor >> 8) & 0xFF;
    int prevB = prevColor & 0xFF;
    // Compute the difference of the red, green, and blue values
    result[0] = abs(currR - prevR);
    result[1] = abs(currG - prevG);
    result[2] = abs(currB - prevB);

    return result;
  }

  void setDiffRef() {
    diffRef = warped.copy();
  }

  void displayCam() {
    image(cam, 0, 0);
  }
  void displayDiffRef() {
    image(diffRef, 0, 0);
  }
  void displayDiffImg() {
    //pushMatrix();
    //scale(scale);
    image(diffImg, 0, 0);
    //popMatrix();
  }
}
