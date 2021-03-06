import gab.opencv.*;
import java.awt.Rectangle;
import processing.video.*;
import controlP5.*;
import com.hamoid.*;

OpenCV opencv;
Capture video;

PImage src, preProcessedImage, processedImage;

VideoExport videoExport;

// CALIBRATION VARS
int PROJECTOR_WIDTH = 640; // old was 640
int PROJECTOR_HEIGHT = 480; // old was 480

// get from calibration program
float contrast = 1.01; 
int threshold = 129;
int blurSize = 4;

int zoom = 0;
int posX = 0;
int posY = 0;

// change if neccesary...
int brightness = 0;

// STATE VARS
boolean mirrorMode = false;
boolean clear=false;
boolean debugging = false;
boolean recording = false;
boolean videoRecording = false;
boolean zoomCalibration = false;

// EFFECT VARS
PImage snapshot;
PImage mirrorSnapshot;

//gif
PImage curr_frame;
ArrayList<PImage> newGifFrames = new ArrayList<PImage>();
ArrayList<PImage> gifFrames = new ArrayList<PImage>();
int gifStartingTime;
int gifRecordingTimePassed = 0;
int gifMaxDuration = 5000;
int gifFrameIndex = 0;
boolean gifForward = true;

void setup() {
  // frameRate(15);
  //video = new Capture(this, PROJECTOR_WIDTH, PROJECTOR_HEIGHT);
  video = new Capture(this, PROJECTOR_WIDTH, PROJECTOR_HEIGHT, "USB Camera");
  video.start();
  
  opencv = new OpenCV(this, PROJECTOR_WIDTH, PROJECTOR_HEIGHT);
  
  size(1024, 768, P2D); // SHOULD MATCH PROJECTOR DIMENSIONS
  
  snapshot = loadImage("blankbg.jpg");
  
  println("debugging: " + debugging);
  videoExport = new VideoExport(this);
  videoExport.setDebugging(debugging);  
}

void draw() {
  if (video.available()) {
    video.read();
  }
  opencv.loadImage(video);
  src = opencv.getSnapshot();
  
  // ******************** <1> PRE-PROCESS IMAGE ********************
  opencv.gray();
  //opencv.brightness(brightness);
  opencv.contrast(contrast);
  
  // Save snapshot for display
  preProcessedImage = opencv.getSnapshot();
  
  // ******************** PROCESS IMAGE ********************
  // - Threshold
  // - Noise Supression
  
  opencv.threshold(threshold);

  // Invert (black bg, white blobs)
  opencv.invert();
  
  // Reduce noise - Dilate and erode to close holes
  opencv.dilate();
  opencv.erode();

  opencv.blur(blurSize);
  
  opencv.invert();

  processedImage = opencv.getSnapshot();

  // ******************** DRAWING ********************
  background(255); 
  if (clear == true) {
    snapshot = loadImage("blankbg.jpg");
    gifFrames = new ArrayList<PImage>();   
    clear = false;
  }

  if (gifFrames.size() > 0) {
    if (gifForward) {
      image(gifFrames.get(gifFrameIndex), posX - zoom/2, posY - zoom/2, width + zoom, height + zoom); // SHOW      
      gifFrameIndex += 1;
      if (gifFrameIndex == gifFrames.size()) {
        gifForward = false;
        gifFrameIndex = gifFrames.size() - 1;
      } 
    } else {  
      image(gifFrames.get(gifFrameIndex), posX - zoom/2, posY - zoom/2, width + zoom, height + zoom); // SHOW
      gifFrameIndex -= 1;
      if (gifFrameIndex < 0) {
        gifForward = true;
        gifFrameIndex = 0;
      }      
    }


  } else { // just static
    image(snapshot, posX - zoom/2, posY - zoom/2, width + zoom, height + zoom); // SHOW   
  }

  if (mirrorMode) {
    mirrorSnapshot = opencv.getSnapshot(); // get whatever is currently on opencv, should be processed image video feed
    pushMatrix();
    translate(mirrorSnapshot.width,0);
    scale(-1,1);
    image(mirrorSnapshot, posX - zoom/2, posY - zoom/2, width + zoom, height + zoom); // SHOW
    popMatrix();  
  } 

  if (videoRecording) {
    videoExport.saveFrame();
  } 

  if (recording) {
      curr_frame = opencv.getSnapshot();
      newGifFrames.add(curr_frame);
      
      // PRINT HOW MUCH TIME IT HAS PASSED FROM RECORDING EVERY SECOND
      if (millis() > gifStartingTime + 1000) {
        println(millis());
        gifRecordingTimePassed += 1;
        println("time passed: "  + gifRecordingTimePassed);
      }

      // DONE WITH RECORDING
      if (millis() > gifStartingTime + gifMaxDuration) {
        recording = false;
        gifFrames = newGifFrames;
        println("stop recording");
      }    
  }

  if (debugging) {
    if (zoomCalibration == true) {
      //zoom = mouseX;
      // println("zoom: " + zoom);
      image(processedImage, 0, 0, (width + zoom)/4, (height + zoom)/4);    
      image(processedImage, posX - zoom/2, posY - zoom/2, width + zoom, height + zoom);    
    }
    image(processedImage, 0, 0, width/4, height/4);
  } 

}


void keyReleased() {
  if (key == 's' || key == 'S') {
    //snapshot = get();
    snapshot = opencv.getSnapshot(); // get whatever is currently on opencv, should be processed image video feed
    println("snapshot");
  }
  if (key == 'm' || key == 'M') {
    mirrorMode = !mirrorMode;
    println("mirror");
    print(mirrorMode);
  }  

  if (key == 'd' || key == 'D') {
    debugging = !debugging;
    println("debugging: " + debugging);
  }

  if (key == 'z' || key == 'Z') {
    zoomCalibration = !zoomCalibration;
    println("zoom calibration: " + zoomCalibration);
  }
  
  if (key == 'c' || key == 'C') {
    clear = true;
    println("clear");
  }   

  if (key == 'r' || key == 'R') {
    println("start recording");
    gifStartingTime = millis();

    newGifFrames = new ArrayList<PImage>();
    // gifFrames = new ArrayList<PImage>(); // clean gif frames
    recording = true;
  }  

  if(key == 'v' || key == 'V') {
    if (videoRecording == true) {
      videoRecording = !videoRecording;
      videoExport.endMovie();   
    } else {
      videoRecording = !videoRecording;
      videoExport.setMovieFileName(frameCount + ".mp4");
      videoExport.startMovie();
      println("Start movie.");
    }
  }
  
  if (key == 'q') {
    if (videoRecording == true) {
      videoExport.endMovie();
    }
    exit();
  }
}

void keyPressed() {
  if (key == 'o' || key == 'O') {
    zoom += 10;
    println("zoom: " + zoom);
  } else if (key == 'l' || key == 'L') {
    zoom -= 10;
    println("zoom: " + zoom);
  }

  if (key == CODED) {
    if (keyCode == UP) {

      posY += 10;
      println("posY:" + posY);

    } else if (keyCode == DOWN) {

      posY -= 10;
      println("posY:" + posY);

    } else if (keyCode == LEFT) {

      posX -= 10;
      println("posX:" + posX);

    } else if (keyCode == RIGHT) {

      posX += 10;
      println("posX:" + posX);

    }      
  }
}