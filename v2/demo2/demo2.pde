import gab.opencv.*;
import SimpleOpenNI.*;
import KinectProjectorToolkit.*;

SimpleOpenNI kinect;
OpenCV opencv;
KinectProjectorToolkit kpc;
ArrayList<ProjectedContour> projectedContours;
ArrayList<PGraphics> projectedGraphics;

PImage snapshot;
PImage mirrorSnapshot;

boolean mirrorMode = false;

void setup()
{
  size(displayWidth, displayHeight, P2D); 

  // setup Kinect
  kinect = new SimpleOpenNI(this); 
  kinect.enableDepth();
  kinect.enableUser();
  kinect.alternativeViewPointDepthToImage();
  
  // setup OpenCV
  opencv = new OpenCV(this, kinect.depthWidth(), kinect.depthHeight());

  // setup Kinect Projector Toolkit
  kpc = new KinectProjectorToolkit(this, kinect.depthWidth(), kinect.depthHeight());
  kpc.loadCalibration("calibration.txt");
  kpc.setContourSmoothness(4);
  
  projectedGraphics = initializeProjectedGraphics();
  
  snapshot = loadImage("latest.jpg");
}

void draw()
{  
  kinect.update();  
  kpc.setDepthMapRealWorld(kinect.depthMapRealWorld()); 
  kpc.setKinectUserImage(kinect.userImage());
  opencv.loadImage(kpc.getImage());
  
  // get projected contours
  projectedContours = new ArrayList<ProjectedContour>();
  ArrayList<Contour> contours = opencv.findContours();
  for (Contour contour : contours) {
    if (contour.area() > 2000) {
      ArrayList<PVector> cvContour = contour.getPoints();
      ProjectedContour projectedContour = kpc.getProjectedContour(cvContour, 1.0);
      projectedContours.add(projectedContour);
    }
  }
  
  // draw projected contours
  background(255);
  image(snapshot, 0, 0);
  
  PImage cameraIcon = loadImage("camera_icon.png");
  image(cameraIcon, displayWidth - 100, 0);

  PImage mirrorIcon = loadImage("mirror_icon.png");
  image(mirrorIcon, displayWidth - 160, 0);

  for (int i=0; i<projectedContours.size(); i++) {
    ProjectedContour projectedContour = projectedContours.get(i);
    PGraphics pg = projectedGraphics.get(i%3);    
    beginShape();
    texture(pg);
    for (PVector p : projectedContour.getProjectedContours()) {
      PVector t = projectedContour.getTextureCoordinate(p);
      vertex(p.x, p.y, pg.width * t.x, pg.height * t.y);
    }
    endShape();
  }
  
  if (mirrorMode == true) {
    mirrorSnapshot = get();
    pushMatrix();
    translate(mirrorSnapshot.width,0);
    scale(-1,1);
    image(mirrorSnapshot,0,0);
    popMatrix();  
  }

  
}

ArrayList<PGraphics> initializeProjectedGraphics() {
  ArrayList<PGraphics> projectedGraphics = new ArrayList<PGraphics>();
  for (int p=0; p<3; p++) {
    color col = color(0);
    PGraphics pg = createGraphics(800, 400, P2D);
    pg.beginDraw();
    pg.background(0);
    pg.endDraw();
    projectedGraphics.add(pg);
  }  
  return projectedGraphics;
}


//save image
void keyReleased() {
  if (key == 's' || key == 'S') {
    snapshot = get();
    println("snapshot");
  }
  if (key == 'm' || key == 'M') {
    mirrorMode = !mirrorMode;
  }  
  
}


