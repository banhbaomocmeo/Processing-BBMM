PImage img, img2;
int k=100;
int[] labels;
int it = 0;
HSV[] K;
int[] counts;
HSV[] avgs;
HSV[] HSVPixels;


void setup(){
  //frameRate(1);
  size(1600,800);
  img = loadImage("test.png");
  img.resize(800, 800);
  img.loadPixels();
  img2 = createImage(img.width, img.height, RGB);
  
  K = new HSV[k];
  HSVPixels = new HSV[img.height*img.width];
  labels = new int[img.height*img.width];
  for(int i=0; i<labels.length; ++i){
    HSVPixels[i] = new HSV();
    HSVPixels[i].RGBtoHSV(img.pixels[i]);
    labels[i] = -1;
  }
  counts = new int[k];
  avgs = new HSV[k];
  for(int i=0; i<k; i++){
    avgs[i] = new HSV();
  }
  
  
  KmeansInitCenters(K);
}  

void draw(){
  img.loadPixels();
  KmeansAssignLabels(HSVPixels, K);
  KmeansUpdateCenters(HSVPixels, K);
  display(img, img2, K);
}

void KmeansInitCenters(HSV[] K){
  for(int i = 0; i < k; i++){
    K[i] = new HSV();
    K[i].h = floor(random(TWO_PI));
    K[i].s = floor(random(1));
    K[i].v = floor(random(1));
  }
  //K[6] = new PVector(255,0,0);
  //K[1] = new PVector(0,255,0);
  //K[2] = new PVector(0,0,255);
  //K[0] = new PVector(0,255,255);
  //K[4] = new PVector(255,0,255);
  //K[5] = new PVector(255,255,0);
  //K[3] = new PVector(255,255,255);
}

void KmeansAssignLabels(HSV[] hsvP, HSV[] K){
  for(int i=0; i<hsvP.length; i++){
    float minD = width*height;
    for(int j=0; j<K.length; j++){
      
      float d = dist(hsvP[i].h, hsvP[i].s, hsvP[i].v, K[j].h, K[j].s, K[j].v);
      if(minD >= d){
        minD = d;
        labels[i] = j;
        //print(labels[i]+"\n");
      }
    }
  }
}

void KmeansUpdateCenters(HSV[] HSVPixels, HSV[] K){
  for(int i=0; i<K.length; i++){
    avgs[i].h = 0;
    avgs[i].s = 0;
    avgs[i].v = 0;
    counts[i] = 0;
  }
  for(int i=0; i<HSVPixels.length; i++){
    avgs[labels[i]].h += HSVPixels[i].h;
    avgs[labels[i]].s += HSVPixels[i].s;
    avgs[labels[i]].v += HSVPixels[i].v;
    counts[labels[i]] ++;
  }
  for(int i=0; i<K.length; i++){
    if(counts[i] !=0){
      K[i].h = avgs[i].h / counts[i];
      K[i].s = avgs[i].s / counts[i];
      K[i].v = avgs[i].v / counts[i];
    }
  }
}

void display(PImage img, PImage img2, HSV[] K){
  for(int i=0; i<img2.pixels.length; i++){
    if(labels[i] != -1){
      img.pixels[i] = K[labels[i]].HSVtoRGB();
    }
  }
  img2.updatePixels();
  image(img, 0, 0);
  image(img2, 800, 0);
  print("ok");
}

//0-1
class HSV{
  float h;
  float s;
  float v;
  
  public HSV(){
    h=0;
    s=0;
    v=0;
  }
  
  void RGBtoHSV(color clr){
    float _r = (clr >> 16 & 0xFF)/255.0;
    float _g = (clr >> 4 & 0xFF)/255.0;
    float _b = (clr & 0xFF)/255.0;
    
    float cMax = max(_r,_g,_b);
    float cMin = min(_r,_g,_b);
    float delta = cMax - cMin;
    
    //Hue 0-2PI
    if(delta == 0){
      this.h = 0;
    }else if(cMax == _r){
      this.h = PI/3 * (_g - _b) / delta;
    }else if(cMax == _g){
      this.h = PI/3 * (2 + (_b - _r) / delta);
    }else if(cMax == _b){
      this.h = PI/3 * (4 + (_r - _g) / delta);
    }
    if(this.h < 0){
      this.h = 2 * PI + this.h;
    }
    
    //Saturation 0-1
    if(cMax == 0){
      this.s = 0;
    }else{
      this.s = delta / cMax;
    }
    
    //Value 0-1
    this.v = cMax;
  }
  
  color HSVtoRGB(){
    float r = 0;
    float g = 0;
    float b = 0;
    
        if(s == 0) {
        // Achromatic (grey)
        r = g = b = this.v;
        return color(r*255, g*255, b*255);
    }
     
    h = h * 3 / PI; // sector 0 to 5
    int i = floor(h);
    float f = h - i; // factorial part of h
    float p = v * (1 - s);
    float q = v * (1 - s * f);
    float t = v * (1 - s * (1 - f));
     
    switch(i) {
        case 0:
            r = v;
            g = t;
            b = p;
            break;
     
        case 1:
            r = q;
            g = v;
            b = p;
            break;
     
        case 2:
            r = p;
            g = v;
            b = t;
            break;
     
        case 3:
            r = p;
            g = q;
            b = v;
            break;
     
        case 4:
            r = t;
            g = p;
            b = v;
            break;
     
        default: // case 5:
            r = v;
            g = p;
            b = q;
    }
    
    return color(r*255, g*255, b*255);
  }
}