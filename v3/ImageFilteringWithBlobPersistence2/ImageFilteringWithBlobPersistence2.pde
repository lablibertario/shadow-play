import gab.opencv.*;
import java.awt.Rectangle;
import processing.video.*;
import controlP5.*;

OpenCV opencv;
Capture video;
PImage src, preProcessedImage, processedImage;

// CALIBRATION VARS

int PROJECTOR_WIDTH = 1024; // old was 640
int PROJECTOR_HEIGHT = 768; // old was 480
float contrast = 1.35;
int brightness = 0;
int threshold = 75;
int blurSize = 4;

// PImage contoursImage;
// ArrayList<Contour> contours;
// ArrayList<Contour> newBlobContours; // List of detected contours parsed as blobs (every frame)
// ArrayList<Blob> blobList; // List of my blob objects (persistent)
// int blobCount = 0; // Number of blobs detected over all time. Used to set IDs.
// int blobSizeThreshold = 20;

void setup() {
  frameRate(15);
  
  video = new Capture(this, PROJECTOR_WIDTH, PROJECTOR_HEIGHT);
  //video = new Capture(this, 640, 480, "USB2.0 PC CAMERA");

  video.start();
  
  opencv = new OpenCV(this, PROJECTOR_WIDTH, PROJECTOR_HEIGHT);
  // contours = new ArrayList<Contour>();
  // blobList = new ArrayList<Blob>();
  
  size(1024, 768, P2D);
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
  
  opencv.invert(); // TODO (figure out if we should be calling this twice!)

  processedImage = opencv.getSnapshot();
  
  image(processedImage, 0, 0);
  
  
    
  // ******************** <1>  FIND CONTOURS   ********************
  //detectBlobs();
  //// Passing 'true' sorts them by descending area.
  ////contours = opencv.findContours(true, true);
  
  //// Save snapshot for display
  //// contoursImage = opencv.getSnapshot();
  
  // Draw
  // pushMatrix();
  //   displayImages();
    
  //   // Display contours in the lower right window
  //   pushMatrix();
  //     scale(0.5);
  //     translate(src.width, src.height);
      

  //     // ----- Contours ----- (DETECTION)
  //     // displayContours();
  //     // displayContoursBoundingBoxes();
  //     // displayBlobs();
      
  //   popMatrix(); 
    
  // popMatrix();
}

// void displayImages() {
  
//   pushMatrix();
//   scale(0.5);
//   image(src, 0, 0);
//   image(preProcessedImage, src.width, 0);
//   image(processedImage, 0, src.height);
//   image(src, src.width, src.height);
//   popMatrix();
  
//   stroke(255);
//   fill(255);
//   textSize(12);
//   text("Source", 10, 25); 
//   text("Pre-processed Image", src.width/2 + 10, 25); 
//   text("Processed Image", 10, src.height/2 + 25); 
//   text("Tracked Points", src.width/2 + 10, src.height/2 + 25);
// }

// void displayBlobs() {
  
//   for (Blob b : blobList) {
//     strokeWeight(1);
//     b.display();
//   }
// }

// void displayContours() {
  
//   // Contours
//   for (int i=0; i<contours.size(); i++) {
  
//     Contour contour = contours.get(i);
    
//     noFill();
//     stroke(0, 255, 0);
//     strokeWeight(3);
//     contour.draw();
//   }
// }

// void displayContoursBoundingBoxes() {
  
//   for (int i=0; i<contours.size(); i++) {
    
//     Contour contour = contours.get(i);
//     Rectangle r = contour.getBoundingBox();
    
//     if (//(contour.area() > 0.9 * src.width * src.height) ||
//         (r.width < blobSizeThreshold || r.height < blobSizeThreshold))
//       continue;
    
//     stroke(255, 0, 0);
//     fill(255, 0, 0, 150);
//     strokeWeight(2);
//     rect(r.x, r.y, r.width, r.height);
//   }
// }

// void detectBlobs() {
  
//   // Contours detected in this frame
//   // Passing 'true' sorts them by descending area.
//   contours = opencv.findContours(true, true);
  
//   newBlobContours = getBlobsFromContours(contours);
  
//   //println(contours.length);
  
//   // Check if the detected blobs already exist are new or some has disappeared. 
  
//   // SCENARIO 1 
//   // blobList is empty
//   if (blobList.isEmpty()) {
//     // Just make a Blob object for every face Rectangle
//     for (int i = 0; i < newBlobContours.size(); i++) {
//       println("+++ New blob detected with ID: " + blobCount);
//       blobList.add(new Blob(this, blobCount, newBlobContours.get(i)));
//       blobCount++;
//     }
  
//   // SCENARIO 2 
//   // We have fewer Blob objects than face Rectangles found from OpenCV in this frame
//   } else if (blobList.size() <= newBlobContours.size()) {
//     boolean[] used = new boolean[newBlobContours.size()];
//     // Match existing Blob objects with a Rectangle
//     for (Blob b : blobList) {
//        // Find the new blob newBlobContours.get(index) that is closest to blob b
//        // set used[index] to true so that it can't be used twice
//        float record = 50000;
//        int index = -1;
//        for (int i = 0; i < newBlobContours.size(); i++) {
//          float d = dist(newBlobContours.get(i).getBoundingBox().x, newBlobContours.get(i).getBoundingBox().y, b.getBoundingBox().x, b.getBoundingBox().y);
//          //float d = dist(blobs[i].x, blobs[i].y, b.r.x, b.r.y);
//          if (d < record && !used[i]) {
//            record = d;
//            index = i;
//          } 
//        }
//        // Update Blob object location
//        used[index] = true;
//        b.update(newBlobContours.get(index));
//     }
//     // Add any unused blobs
//     for (int i = 0; i < newBlobContours.size(); i++) {
//       if (!used[i]) {
//         println("+++ New blob detected with ID: " + blobCount);
//         blobList.add(new Blob(this, blobCount, newBlobContours.get(i)));
//         //blobList.add(new Blob(blobCount, blobs[i].x, blobs[i].y, blobs[i].width, blobs[i].height));
//         blobCount++;
//       }
//     }
  
//   // SCENARIO 3 
//   // We have more Blob objects than blob Rectangles found from OpenCV in this frame
//   } else {
//     // All Blob objects start out as available
//     for (Blob b : blobList) {
//       b.available = true;
//     } 
//     // Match Rectangle with a Blob object
//     for (int i = 0; i < newBlobContours.size(); i++) {
//       // Find blob object closest to the newBlobContours.get(i) Contour
//       // set available to false
//        float record = 50000;
//        int index = -1;
//        for (int j = 0; j < blobList.size(); j++) {
//          Blob b = blobList.get(j);
//          float d = dist(newBlobContours.get(i).getBoundingBox().x, newBlobContours.get(i).getBoundingBox().y, b.getBoundingBox().x, b.getBoundingBox().y);
//          //float d = dist(blobs[i].x, blobs[i].y, b.r.x, b.r.y);
//          if (d < record && b.available) {
//            record = d;
//            index = j;
//          } 
//        }
//        // Update Blob object location
//        Blob b = blobList.get(index);
//        b.available = false;
//        b.update(newBlobContours.get(i));
//     } 
//     // Start to kill any left over Blob objects
//     for (Blob b : blobList) {
//       if (b.available) {
//         b.countDown();
//         if (b.dead()) {
//           b.delete = true;
//         } 
//       }
//     } 
//   }
  
//   // Delete any blob that should be deleted
//   for (int i = blobList.size()-1; i >= 0; i--) {
//     Blob b = blobList.get(i);
//     if (b.delete) {
//       blobList.remove(i);
//     } 
//   }
// }

// ArrayList<Contour> getBlobsFromContours(ArrayList<Contour> newContours) {
  
//   ArrayList<Contour> newBlobs = new ArrayList<Contour>();
  
//   // Which of these contours are blobs?
//   for (int i=0; i<newContours.size(); i++) {
    
//     Contour contour = newContours.get(i);
//     Rectangle r = contour.getBoundingBox();
    
//     if (//(contour.area() > 0.9 * src.width * src.height) ||
//         (r.width < blobSizeThreshold || r.height < blobSizeThreshold))
//       continue;
    
//     newBlobs.add(contour);
//   }
  
//   return newBlobs;
// }