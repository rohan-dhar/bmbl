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
  
  public void init(){
    this.bg.x = 0;
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
  int x, y, size, maxX, screenWidth, screenHeight, undoLeft;
  
  ArrayList <Integer> colors = new ArrayList();
  ArrayList <Integer> colorsToMatch = new ArrayList();
  
  public Player(int size, int maxX, int screenWidth, int screenHeight){
    this.size = size;
    this.maxX = maxX;
    this.screenWidth = screenWidth;
    this.screenHeight = screenHeight;
  }
  
  public void init(color bgColor, color colorsToMatch[], int colorsNum){    
    this.x = this.screenWidth/2;
    this.y = 0;
    this.undoLeft = 5;
    this.colors.clear();
    this.colorsToMatch.clear();
    this.colors.add(bgColor);
    for(int i = 0; i < colorsNum; i++){
      this.colorsToMatch.add(colorsToMatch[i]);
    }
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
  
  public boolean undo(){
    if(this.undoLeft > 0){
      if(this.colors.size() == 1){
        return true;
      }
      this.colors.remove(this.colors.size()-1);
      this.undoLeft--;
      return true;
    }
    return false;
  } 
  
  public void render(){    
    int r = this.size / this.colors.size();
    stroke(0,0,0,30);
    for(int i = this.colors.size(); i > 0; i--){
      fill(this.colors.get(i-1));
      ellipse(this.x, this.y, r*i, r*i);  
    }
    
    r = this.size / this.colorsToMatch.size();
    stroke(0,0,0,20);
    for(int i = this.colorsToMatch.size(); i > 0; i--){
      fill(this.colorsToMatch.get(i-1));
      ellipse(this.size/2 + 50, this.screenHeight - this.size/2 - 50, r*i, r*i);  
    }
    
    noStroke();
    fill(255,255,255,150);
    textSize(20);
    text("UNDO LEFT", 50, 70);
    fill(255,255,255);
    textSize(34);
    text(((this.undoLeft != 0)?Integer.toString(this.undoLeft):"NONE :("), 50, 115);
  }
  
  public int hasWon(){
    if(this.colors.equals(this.colorsToMatch)){
      return 1;
    }else{
      int incorrect = 0;
      for(int i = 0; i < this.colors.size() && i < this.colorsToMatch.size(); i++){
        if(!this.colors.get(i).equals(this.colorsToMatch.get(i))){
          incorrect++;
        }
      }
      if(incorrect > this.undoLeft){
        return 2;
      }else{
        return 0;
      }
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
  
  public void init(){
    this.blocks.clear();
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
};

class Button{
  int x, y, h, w;
  String text;
  color bgColor, textColor;
  public Button(String text, int x, int y, int w, int h, color bgColor, color textColor){
    this.text = text;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;    
    this.bgColor = bgColor;
    this.textColor = textColor;
  }
  
  public void render(){
    fill(this.bgColor);
    rect(x, y, w, h);
    fill(this.textColor);
    textSize(14);
    text(this.text, x + 30, y + 34);
  }
}

class Menu{
  Button btns[] = new Button[2];
  public Menu(String gameName, int screenWidth, int screenHeigh){
    this.btns[0] = new Button("SINGLE PLAYER", 600, screenHeight - 160, 170, 60, GREEN, color(255));
    this.btns[1] = new Button("TWO PLAYER", 800, screenHeight - 160, 160, 60, BLUE, color(255));    
  }
}
