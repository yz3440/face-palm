import org.opencv.imgproc.Imgproc;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.Point;
import org.opencv.core.Size;
import org.opencv.core.Mat;
import org.opencv.core.CvType;



class ImageWarper {
  OpenCV opencv;
  JSONObject json;
  PImage warped;
  Mat transform;
  ArrayList<PVector> vectors = new ArrayList<PVector>();
  
  ImageWarper(PApplet sketchRef, Capture video) {
    warped = createImage(1920, 1080, RGB); 
    //load data
    json = loadJSONObject("coords.json");
    JSONArray coordsData = json.getJSONArray("coords");
    for (int i = 0; i < coordsData.size(); i++) {
      // Get each object in the array
      JSONObject coord = coordsData.getJSONObject(i); 
      // Get a position object
      JSONObject position = coord.getJSONObject("position");
      // Get x,y from position
      int x = position.getInt("x");
      int y = position.getInt("y");
      vectors.add(new PVector(x, y, 0.0));
    }
    opencv = new OpenCV(sketchRef, video);
  }
  Mat getPerspectiveTransformation(ArrayList<PVector> inputPoints, int w, int h) {
    Point[] canonicalPoints = new Point[4];
    canonicalPoints[0] = new Point(w, 0);
    canonicalPoints[1] = new Point(0, 0);
    canonicalPoints[2] = new Point(0, h);
    canonicalPoints[3] = new Point(w, h);

    MatOfPoint2f canonicalMarker = new MatOfPoint2f();
    canonicalMarker.fromArray(canonicalPoints);

    Point[] points = new Point[4];
    for (int i = 0; i < 4; i++) {
      points[i] = new Point(inputPoints.get(i).x, inputPoints.get(i).y);
    }
    MatOfPoint2f marker = new MatOfPoint2f(points);
    return Imgproc.getPerspectiveTransform(marker, canonicalMarker);
  }

  Mat warpPerspective(ArrayList<PVector> inputPoints, int w, int h) {
    Mat transform = getPerspectiveTransformation(inputPoints, w, h);
    Mat unWarpedMarker = new Mat(w, h, CvType.CV_8UC1);    
    Imgproc.warpPerspective(opencv.getColor(), unWarpedMarker, transform, new Size(w, h));
    return unWarpedMarker;
  }

  PImage warp(PImage img) {
    opencv.loadImage(img);
    opencv.toPImage(warpPerspective(vectors, 1920, 1080), warped);
    return warped;
  }
}
