class FaceCam {
  Capture cam;
  OpenCV opencv;
  PImage faceImg;
  PImage smallerImg;
  int scale;
  int resolution;
  float cropFactor;

  FaceCam(PApplet sketchRef, int cvScale, int faceResolution, float cropFactor) {
    this.cam = new Capture(sketchRef, 1280,720,intCam,30);
    this.cam.start();
    this.opencv = new OpenCV(sketchRef, this.cam.width/cvScale,  this.cam.height/cvScale);
    this.opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);

    this.resolution = faceResolution;
    this.scale = cvScale;
    this.cropFactor = cropFactor;

    this.faceImg = createImage(faceResolution, faceResolution, RGB);
    this.smallerImg = createImage(opencv.width, opencv.height, RGB);
  }

  void updateSmallerImg() {
    this.smallerImg.copy(this.cam, 
      0, 0, this.cam.width, this.cam.height, 
      0, 0, this.smallerImg.width, this.smallerImg.height);
    this.smallerImg.updatePixels();
  }

  void updateFace() {
    this.opencv.loadImage(this.smallerImg);
    Rectangle[] faces = opencv.detect();

    if (faces != null && faces.length > 0) {
      //get the largest bounding box
      Rectangle biggestRect = faces[0];
      for (int i = 1; i < faces.length; i++) {
        if (faces[i].width > biggestRect.width)
          biggestRect = faces[i];
      }
      this.faceImg.copy(this.cam, biggestRect.x * this.scale, biggestRect.y * this.scale, 
        biggestRect.width * this.scale, biggestRect.height * this.scale, 
        0, 0, this.resolution, this.resolution);
      cropFace();
    }
  }

  void cropFace() {
    if (this.cropFactor > 1) {
      int w = int(this.faceImg.width * 1.0 / this.cropFactor);
      int h = int(this.faceImg.height * 1.0 / this.cropFactor);
      this.faceImg.copy(this.faceImg, int((this.faceImg.width - w)*.5), int((this.faceImg.height - h)*.5), 
        w, h, 
        0, 0, this.faceImg.width, this.faceImg.height);
    }
  }

  void update() {
    updateSmallerImg();
    updateFace();
  }

  PImage getFace() {
    return this.faceImg;
  }

  void displayCam() {
    image(this.cam, 0, 0);
  }
}
