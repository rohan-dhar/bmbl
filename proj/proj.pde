// Core Constants and settings
final int screenWidth = 1200, 
          screenHeight = 900,
          blockSize = 80;

final int colorsNum = 4;

color colors[] = {color(46,204,170), color(34,167,240), color(238,221,85), color(238,221,85)};

// Basic Data 
Floor floor;
Player p = new Player(80, color(255, 138, 133));
BlockManager blocks = new BlockManager(blockSize, screenWidth);

int speed = 6;
float blockProbability = 0.02;

void setup(){
  size(1200, 900);
  floor = new Floor("bg1.png", screenWidth, screenHeight);
}

void draw(){
  
  floor.render();
  floor.next(speed);
    
  if(random(1) <= blockProbability){
    color c = colors[(int)random(colorsNum)];
    int y = (int)random(blockSize/2, screenHeight - blockSize);
    blocks.add(c, y);
  }
  
  blocks.next(speed*2);
  blocks.render();
  
  p.x = mouseX;
  p.y = mouseY;
  
  
  p.render();
}
