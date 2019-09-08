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
  
  Element bg, bgCopy;
  int screenDelta, screenWidth;
  
  public Floor(String bgImg, int screenWidth, int screenHeight){
    this.bg = new Element(bgImg, 0, 0, 0, screenHeight);
    this.bg.w = (int)((float)this.bg.img.width / (float)this.bg.img.height * (float)screenHeight);

    this.bgCopy = new Element(bgImg, 0, 0, 0, screenHeight);
    this.bgCopy.w = (int)((float)this.bg.img.width / (float)this.bg.img.height * (float)screenHeight);

    this.screenWidth = screenWidth;
    this.screenDelta = this.bg.w - screenWidth;
  }
    
  public void next(int speed){
    if(Math.abs(this.bg.x) >= this.bg.w){
      this.bg.x = 0;
    }else{
      this.bg.x -= speed;
    }
  }

  public void render(){    
    if(-this.bg.x > this.screenDelta){
      this.bg.render();
      int wid = (-this.bg.x) - this.screenDelta;
      this.bgCopy.x = this.screenWidth - wid;
      this.bgCopy.render();
    }else{
      this.bg.render();
    }
  }
}  

class Player{
  int x, y, size, maxX, screenWidth;
  ArrayList <Integer> colors = new ArrayList();
  public Player(int size, color bgColor, int maxX, int screenWidth){
    this.x = screenWidth/2;
    this.y = screenHeight/2;
    
    this.size = size;
    this.colors.add(bgColor);
    
    this.maxX = maxX;
    this.screenWidth = screenWidth;
  }
  
  public void move(int x, int y){
    if(x >= this.screenWidth/2 - maxX && x <= screenWidth/2 + maxX){
      this.x = x;
    }else if(x < this.screenWidth/2 - maxX){
      this.x = this.screenWidth/2 - maxX;
    }else{
      this.x = this.screenWidth/2 + maxX;
    }
    this.y = y;
  }
  
  public void render(){    
    int r = this.size / this.colors.size();
    for(int i = this.colors.size(); i > 0; i--){
      fill(this.colors.get(i-1));
      ellipse(this.x, this.y, r*i, r*i);  
    }
  }
}

class Block{
  color c;
  int x, y, size;
  
  public Block(color c, int x, int y, int size){
    this.x = x;
    this.y = y;
    this.c = c;
    this.size = size;
  }

  public void render(){
    fill(this.c);
    ellipse(this.x, this.y, this.size, this.size);    
  }
}

class BlockManager{
  

  int blockSize, screenWidth; 
  ArrayList<Block> blocks = new ArrayList();
  
  public BlockManager(int blockSize, int screenWidth){
    this.blockSize = blockSize;
    this.screenWidth = screenWidth;    
  }
  
  public void add(color c, int y){
    Block b = new Block(c, this.screenWidth + this.blockSize/2, y, this.blockSize);
    this.blocks.add(b);
  }
    
  public void next(int speed){
    for(int i = 0; i < this.blocks.size(); i++){
      Block b = this.blocks.get(i);
      if(b.x < -b.size/2){
        this.blocks.remove(i);
      }else{
        b.x -= speed;
        this.blocks.set(i, b); 
      }
    }
  }

  public color detectCollision(int x, int y, int playerSize){
    for(int i = 0; i < this.blocks.size(); i++){
      Block b = blocks.get(i);
      float dist = (b.x - x)*(b.x - x) + (b.y - y)*(b.y - y);
      dist = (float)Math.sqrt(dist);
      if(dist <= (playerSize/2 + b.size/2)){
        this.blocks.remove(i);
        return b.c;
      }
    }
    return color(0, 0, 0);
  }

  public void render(){
    for(int i = 0; i < this.blocks.size(); i++){
      this.blocks.get(i).render();
    }
  }

}
