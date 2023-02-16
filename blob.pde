
//this file is used to track blobs and is mostly written from a tutorial 
//from dan shiffman's coding rainbow but i changed the display from the pixels and blobs 
//to ellipses to represent where the players are standing
//Daniel Shiffman
//http://codingrainbow.com

//the location of the players on the grid is determined by the raw infrared data from an xbox kinect installed overhead

//create a class so that instances can be delegated to each player
class Blob {

  //initialize class variables
  float minx;
  float miny;
  float maxx;
  float maxy;

  int id = 0;
  
  int timer = 50;
  
  float centerOfBlobX;
  float centerOfBlobY;
  
  boolean taken = false;

  ArrayList<PVector> points;

  //constructor for creating an instance of blob
  Blob(float x, float y) {
    minx = x;
    miny = y;
    maxx = x;
    maxy = y;
    points = new ArrayList<PVector>();
    points.add(new PVector(x, y));
  }

  //function to place a circle where there are blobs detected
  void show() {
    centerOfBlobX = (maxx - minx)/2 + minx;
    centerOfBlobY = (miny * 2 + maxy * 2)/4;

    centerOfBlobX = map(centerOfBlobX, 0, 640, 0, displayWidth);
    centerOfBlobY = map(centerOfBlobY, 0, 480, 0, displayHeight);

    stroke(255,255,0);
    fill(0);
    strokeWeight(2);
    rectMode(CORNERS);
    ellipse(centerOfBlobX, centerOfBlobY, 100, 100);
  }
  
  void update() {
    timer--;
  }
  
  boolean checkTimer() {
    timer--;
    if(timer < 0){
      return true;
    } else {
      return false;
    }
  }
  
  void become(Blob other){
    minx = other.minx; 
    maxx = other.maxx;
    miny = other.miny;
    maxy = other.maxy;
  }
  
  
  PVector getCenter(){
    float x = centerOfBlobX;
    float y = centerOfBlobY;
    return new PVector(x,y);
  }


  void add(float x, float y) {
    points.add(new PVector(x, y));
    minx = min(minx, x);
    miny = min(miny, y);
    maxx = max(maxx, x);
    maxy = max(maxy, y);
  }

  float size() {
    return (maxx-minx)*(maxy-miny);
  }

  //function to determine if the blob detected is far enough away to be a new blob
  boolean isNear(float x, float y) {

    float cx = max(min(x, maxx), minx);
    float cy = max(min(y, maxy), miny);
    float d = distSq(cx, cy, x, y);


    if (d < distThreshold*distThreshold) {
      return true;
    } else {
      return false;
    }
  }
}