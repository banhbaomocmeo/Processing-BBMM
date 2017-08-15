PImage img, img2;
int k=500;
int[] labels;
int it = 0;
PVector[] K;
int[] counts;
PVector[] avgs; 


void setup(){
  //frameRate(1);
  size(1024,512);
  img = loadImage("Lenna.png");
  img2 = loadImage("Lenna.png");
  //img.resize(410, 258);
  
  img.loadPixels();
  K = new PVector[k];
  labels = new int[img.height*img.width];
  for(int i=0; i<labels.length; ++i){
    labels[i] = -1;
  }
  counts = new int[k];
  avgs = new PVector[k];
  for(int i=0; i<k; i++){
    avgs[i] = new PVector();
  }
  KmeansInitCenters(K);
}  

void draw(){
  img.loadPixels();
  KmeansAssignLabels(img, K);
  KmeansUpdateCenters(img, K);
  display(img, K);
}

void KmeansInitCenters(PVector[] K){
  for(int i = 0; i < k; i++){
    K[i] = new PVector();
    K[i].x = floor(random(255));
    K[i].y = floor(random(255));
    K[i].z = floor(random(255));
  }
  //K[6] = new PVector(255,0,0);
  //K[1] = new PVector(0,255,0);
  //K[2] = new PVector(0,0,255);
  //K[0] = new PVector(0,255,255);
  //K[4] = new PVector(255,0,255);
  //K[5] = new PVector(255,255,0);
  //K[3] = new PVector(255,255,255);
}

void KmeansAssignLabels(PImage img, PVector[] K){
  for(int i=0; i<img.pixels.length; i++){
    float minD = width*height;
    int r = img.pixels[i] >> 16 & 0xFF;
    int g = img.pixels[i] >> 4 & 0xFF;
    int b = img.pixels[i] & 0xFF;
    //print(r+ "\n");
    for(int j=0; j<K.length; j++){
      
      float d = dist((float)r,(float)g,(float)b,K[j].x,K[j].y,K[j].z);
      if(minD >= d){
        minD = d;
        labels[i] = j;
        //print(labels[i]+"\n");
      }
    }
  }
}

void KmeansUpdateCenters(PImage img, PVector[] K){
  for(int i=0; i<K.length; i++){
    avgs[i].x = 0;
    avgs[i].y = 0;
    avgs[i].z = 0;
    counts[i] = 0;
  }
  for(int i=0; i<img.pixels.length; i++){
    int r = img.pixels[i] >> 16 & 0xFF;
    int g = img.pixels[i] >> 4 & 0xFF;
    int b = img.pixels[i] & 0xFF;
    avgs[labels[i]].x += r;
    avgs[labels[i]].y += g;
    avgs[labels[i]].z += b;
    counts[labels[i]] ++;
  }
  for(int i=0; i<K.length; i++){
    K[i].x = avgs[i].x /= counts[i];
    K[i].y = avgs[i].y /= counts[i];
    K[i].z = avgs[i].z /= counts[i];
  }
}

void display(PImage img, PVector[] K){
  for(int i=0; i<img.pixels.length; i++){
    if(labels[i] != -1){
      int r = (int)K[labels[i]].x;
      int g = (int)K[labels[i]].y;
      int b = (int)K[labels[i]].z;
      img.pixels[i] = color(r,g,b);
    }
  }
  img.updatePixels();
  image(img, 0, 0);
  image(img2, 512, 0);
  print("ok");
}