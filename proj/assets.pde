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
    
  public void next(float speed){
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
  int x, y, size, maxX, screenWidth, screenHeight, undoLeft, colorsNum;
  
  ArrayList <Integer> colors = new ArrayList();
  ArrayList <Integer> colorsToMatch = new ArrayList();
  
  public Player(int size, int maxX, int screenWidth, int screenHeight, int colorsNum){
    this.size = size;
    this.maxX = maxX;
    this.screenWidth = screenWidth;
    this.screenHeight = screenHeight;
    this.colorsNum = colorsNum;
  }
  
  public void init(){    
    this.x = this.screenWidth/2;
    this.y = 0;
    this.undoLeft = 5;
    this.colors.clear();
    this.colorsToMatch.clear();    
    for(int i = 0; i < this.colorsNum; i++){
      this.colorsToMatch.add( COLORS[(int)random(COLORS.length)] );
    }
    this.colors.add(this.colorsToMatch.get(0));
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
      int incorrect = 0, firstIncorrect = -1;
      
      for(int i = 0; i < this.colors.size() && i < this.colorsToMatch.size(); i++){
        if(!this.colors.get(i).equals(this.colorsToMatch.get(i))){
          if(firstIncorrect == -1){
            firstIncorrect = i;
          }
          incorrect++;
        }
      }
      if(incorrect > this.undoLeft || (this.colors.size() - firstIncorrect) > this.undoLeft){
        return 2;
      }else{
        return 0;
      }
    }    
  }
  
  public void reset(){
  
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
    
  public void next(float speed){
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



class Game{
  String name, menuOptions[];
  int screenWidth, screenHeight, state, playerColorsNum;
  float speed, blocksProbability;
  
  Player player1;
  Floor floor;
  BlockManager blocks;
  
  public Game(String name, String[] options, int screenWidth, int screenHeight, Player player1, BlockManager blocks, Floor floor, int playerColorsNum, float speed, float blocksProbability){
    this.state = 0;
    this.name = name;
    this.menuOptions = options;
    this.screenWidth = screenWidth;
    this.screenHeight = screenHeight;
    this.player1 = player1;
    this.blocks = blocks;
    this.floor = floor;    
    this.playerColorsNum = playerColorsNum;
    this.speed = speed;
    this.blocksProbability = blocksProbability;
  }
  
  public void renderMenu(){     
     textFont(avenirBold);
     textAlign(LEFT);
     fill(255, 255, 255, 255);
     textSize(130);
     text(this.name, this.screenWidth * 0.1, 250);
     fill(255,255,255,140);
     textSize(40);
     text("Press the number to choose an option", this.screenWidth*0.1, 320);
     fill(255,255,255,160);
     textAlign(LEFT);
     textSize(31);
     for(int i = 0; i < this.menuOptions.length; i++){
       text(Integer.toString(i+1)+": "+this.menuOptions[i], screenWidth*0.1, 390 + i*45);
    }
  }
  
  public void renderPage(){
    if(this.state == 3 || this.state == 4){
      textAlign(CENTER, CENTER);
      fill(255,255,255);
    }
    if(this.state == 3){  
      textSize(90);
      text("YOU WON", this.screenWidth/2, this.screenHeight*0.45);
      fill(255,255,255,150);
      textSize(36);
      text("Press M to see the Main Menu", this.screenWidth/2, this.screenHeight*0.58);    
    }else if(this.state == 4){
      textSize(90);
      text("GAME OVER :(", this.screenWidth/2, this.screenHeight*0.45);
      fill(255,255,255,150);
      textSize(36);
      text("Press M to see the Main Menu", this.screenWidth/2, this.screenHeight*0.58);
    }
}
  
  public void setState(int state){        
    this.state = state;
    if(state == 0){
      this.renderMenu();
    }else if(state == 1){      
      this.floor.init();
      this.blocks.init();
      this.player1.init();
    }else if(state == 3 || state == 4){
      this.renderPage();
    }    
  
  }
  
  public void next(){
    this.floor.next(speed);  
    if(random(1) <= this.blocksProbability){
      color c = COLORS[(int)random(COLORS.length)];
      
      int y = (int)random(this.blocks.blockSize/2, this.screenHeight - this.blocks.blockSize/2);
      this.blocks.add(c, y);
    }
    
    this.blocks.next(speed*2);
    this.blocks.render();
    this.player1.move(mouseX, mouseY);
    this.player1.render();  

    color col = this.blocks.detectCollision(player1.x, player1.y, player1.size);
    
    if(col != color(0, 0, 0)){
      this.player1.colors.add(col);
      int playerState = player1.hasWon(); 
      if(playerState == 1){
        this.setState(3);
      }else if(playerState == 2){
        this.setState(4);        
      }
    }
  }
  
  void handleKeyPress(){
    if(this.state == 0){
      if(key == '1'){
        this.setState(1);
      }
    }else if(this.state == 1){
      if(key == ' '){
        this.player1.undo();
      }
    }else if(this.state == 3 || this.state == 4){
      if(key == 'm' || key == 'M'){
        this.setState(0);
      }    
    }
  }
}
