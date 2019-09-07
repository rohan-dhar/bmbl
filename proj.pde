// Core Constants and settings
final int screenWidth = 1200, 
          screenHeight = 800,
          tileSize = 400;



// Basic Data 
Floor floor;
Player p = new Player(80, color(255, 108, 108));

int speed = 2;

void setup(){
  size(1200, 800);
  floor = new Floor("tile3.jpg", screenWidth, screenHeight, tileSize);
}

void draw(){
  floor.render();
  floor.next(speed);
  //if(mousePressed){
    p.x = mouseX;
    p.y = mouseY;
  //  }
  p.render();
}
