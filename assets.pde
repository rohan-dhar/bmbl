// Basic Image Elements 
class Element{
  public PImage img;
  public int x, y, w, h;
  public Element(String img, int x, int y, int w, int h){
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;    
    
    this.img = loadImage(img);
  }
  
  public void render(){
    image(this.img, this.x, this.y, this.w, this.h);
  }
};


// Floor: Set of multiple tile Elements
class Floor{
  Element[][] tiles;
  int x, tileSize, numX, numY;
  public Floor(String tileImg, int screenWidth, int screenHeight, int tileSize){
    int numX = screenWidth/tileSize + 1, numY = screenHeight/tileSize;
    this.x = 0;
    this.tileSize = tileSize;
    this.numX = numX;
    this.numY = numY;
    this.tiles = new Element[numX][numY];
    for(int i = 0; i < numX; i++){
      for(int j = 0; j < numY; j++){
        this.tiles[i][j] = new Element(tileImg, i*tileSize, j*tileSize, tileSize, tileSize); 
      }
    }
  }
    
  public void next(int speed){
    if(this.x >= this.tileSize){
      this.x = 0;
      for(int i = 0; i < this.numX; i++){
        for(int j = 0; j < this.numY; j++){
          this.tiles[i][j].x = i*this.tileSize;
        }
      }

    }else{
      this.x += speed;
      for(int i = 0; i < this.numX; i++){
        for(int j = 0; j < this.numY; j++){
          this.tiles[i][j].x -= speed;          
        }
      }
    }
    
  }

  public void render(){
    for (int i = 0; i < this.numX; i++){
      for(int j = 0; j < this.numY; j++){
        this.tiles[i][j].render(); 
      }
    }
  }
}  

class Player{
  int x, y, size;
  color bgColor;
  public Player(int size, color bgColor){
    this.x = 100;
    this.y = 100;
    this.size = 100;
    this.bgColor = bgColor;
  }
  
  public void render(){
    noStroke()  ;
    fill(this.bgColor);  
    ellipse(this.x, this.y, this.size, this.size);
    fill(255,255,255, 80);
    ellipse(this.x, this.y, this.size+100, this.size+100);
  }
}
