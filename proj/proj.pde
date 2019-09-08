// Core Constants and settings
final int screenWidth = 1200, 
          screenHeight = 800,
          blockSize = 66,
          colorsNum = 7,
          playerSize = 180,
          playerMaxX = 220;

final color RED = color(255, 138, 133), 
            GREEN = color(46,204,170),
            BLUE = color(110,187,255),
            YELLOW = color(238,221,85),
            PURPLE = color(160,150,255),
            CYAN = color(90,230,235),
            ORANGE = color(255,160,70);

color colors[] = {RED,GREEN, BLUE, YELLOW, PURPLE, CYAN, ORANGE};
PFont font;

// Basic Data 
Floor floor;
Player p = new Player(playerSize, RED, playerMaxX, screenWidth);
BlockManager blocks = new BlockManager(blockSize, screenWidth);

int speed = 6;
float blockProbability = 0.032;

void setup(){
  size(1200, 800);
  floor = new Floor("bg2.png", screenWidth, screenHeight);
  smooth();
  font = createFont("AvenirNext-Bold", 18);
  textFont(font);
  noStroke();
}

void draw(){
  background(0);
  floor.render();
  floor.next(speed);  
  if(random(1) <= blockProbability){
    color c = colors[(int)random(colorsNum)];
    int y = (int)random(blockSize/2, screenHeight - blockSize);
    blocks.add(c, y);
  }
  
  blocks.next(speed*2);
  
  color col = blocks.detectCollision(p.x, p.y, p.size);
  if(col  != color(0, 0, 0) ){
    p.colors.add(col);
  }
  blocks.render();
  
  p.move(mouseX, mouseY);
  p.render();
}

void keyPressed(){
  if(keyCode == ENTER){
    if(!p.undo()){
      fill(255, 255, 255, 90);
      rect(0, 0, screenWidth, screenHeight);
    }
  }
}
