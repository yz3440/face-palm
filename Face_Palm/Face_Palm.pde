import processing.video.*;
import java.awt.Rectangle;
import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import gab.opencv.*;

PApplet sketchRef;
FaceCam faceCam;
HandCam handCam;
Mixer mixer;

String intCam = "HD Pro Webcam C920 #2";
//String intCam = "FaceTime HD Camera";
String extCam= "HD Pro Webcam C920";
//String extCamConfig = "name=HD Pro Webcam C920,size=1920x1080,fps=30";
//String intCamConfig = "name=FaceTime HD Camera,size=1280x720,fps=30";

void setup() {
  fullScreen();
  //size(1920,1080);
  sketchRef = this;
  faceCam = new FaceCam(sketchRef, 4, 400, 1.2);
  handCam = new HandCam(sketchRef, 2, 80, 2000, true);
  mixer = new Mixer(faceCam, handCam);
}
void draw() {
  background(0);
  faceCam.update();

  handCam.updateWarped();
  handCam.updateDiffImg();
  
  //handCam.displayDiffImg();
  
  handCam.updateCVContours(false);
  mixer.updateGraphics();
  //handCam.displayDiffRef();
  //handCam.displayCam();
  //text(frameRate, 10, 10);
  //background(255);
    //handCam.displayDiffImg();
  println(frameRate);
}

void captureEvent(Capture cam) {
  //handCam.setDiffRef();
  cam.read();
}

void keyPressed() {
  if (key == 'd') handCam.setDiffRef();
  if (keyCode == UP) mixer.addToOffset(new PVector(0,-10));
  if (keyCode == DOWN) mixer.addToOffset(new PVector(0,10));
  if (keyCode == LEFT) mixer.addToOffset(new PVector(-10,0));
  if (keyCode == RIGHT) mixer.addToOffset(new PVector(10,0));
  
  
}
