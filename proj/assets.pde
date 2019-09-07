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
    background(0);
    if(Math.abs(this.bg.x) > this.screenDelta){
      this.bg.render();
      int wid = Math.abs(this.bg.x) - this.screenDelta;
      this.bgCopy.x = this.screenWidth - wid;
      this.bgCopy.render();
    }else{
      this.bg.render();
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
    noStroke();
    fill(255,255,255, 80);
    ellipse(this.x, this.y, this.size+150, this.size+150);
    fill(this.bgColor);  
    ellipse(this.x, this.y, this.size, this.size);

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
    noStroke();
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

  public void render(){
    for(int i = 0; i < this.blocks.size(); i++){
      this.blocks.get(i).render();
    }
  }

}
