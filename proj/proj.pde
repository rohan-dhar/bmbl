// Core Constants and settings
final int screenWidth = 1200, 
          screenHeight = 800,
          blockSize = 66,
          colorsNum = 7,
          playerSize = 180,
          playerMaxX = 220,
          playerColorsNum = 8;

final color RED = color(255, 138, 133), 
            GREEN = color(46,204,170),
            BLUE = color(110,187,255),
            YELLOW = color(238,221,85),
            PURPLE = color(160,150,255),
            CYAN = color(90,230,235),
            ORANGE = color(255,160,70);

final color COLORS[] = {RED,GREEN, BLUE, YELLOW, PURPLE, CYAN, ORANGE};
final String gameName = "GAME NAME";

PFont avenirBold;

// Basic Data 
Floor floor;
Player player1 = new Player(playerSize, playerMaxX, screenWidth, screenHeight);
BlockManager blocks = new BlockManager(blockSize, screenWidth);

Menu menu =  new Menu(gameName, screenWidth, screenHeight);


int speed = 6, gameState = 0;
float blockProbability = 0.06;

void startGame(int state){
  gameState = state;
  if(state == 1){
    color playerColors[] = new color[playerColorsNum];
    int start = (int)random(colorsNum);
    playerColors[0] = COLORS[start];
    for(int i = 1; i < playerColorsNum; i++){
      playerColors[i] = COLORS[(int)random(colorsNum)];
    }
    
    floor.init();
    blocks.init();
    player1.init(COLORS[start], playerColors, playerColorsNum);
  }
}

void gameNextStep(){
  background(0);
  floor.render();
  floor.next(speed);  
  if(random(1) <= blockProbability){
    color c = COLORS[(int)random(colorsNum)];
    int y = (int)random(blockSize/2, screenHeight - blockSize);
    blocks.add(c, y);
  }
  
  blocks.next(speed*2);
  
  color col = blocks.detectCollision(player1.x, player1.y, player1.size);
  if(col  != color(0, 0, 0) ){
    player1.colors.add(col);
    int playerState = player1.hasWon(); 
    if(playerState == 1){
      floor.bg.x = 0;
      floor.render();
      textSize(60);
      textSize(70);
      textAlign(CENTER, CENTER);
      text("PLAYER 1 HAS WON", screenWidth/2, screenHeight/2);
      gameState = 3;
      return;
    }else if(playerState == 2){
      floor.bg.x = 0;
      floor.render();
      textSize(70);
      textAlign(CENTER, CENTER);
      text("GAME OVER :(", screenWidth/2, screenHeight/2);
      gameState = 3;   
      return;
    }
  }
  blocks.render();
  
  player1.move(mouseX, mouseY);
  player1.render();
}

void setup(){
  size(1200, 800);
  smooth();
  noStroke();
  floor = new Floor("bg2.png", screenWidth, screenHeight);
  avenirBold = createFont("AvenirNext-Bold", 18);
  textFont(avenirBold);
}

void draw(){
  if(gameState == 0){
    startGame(1);
  }else if(gameState == 1){
    gameNextStep();
  }
}

void keyPressed(){
  if(keyCode == ENTER && gameState == 1){
    if(!player1.undo()){
      fill(255, 255, 255, 90);
      rect(0, 0, screenWidth, screenHeight);
    }
  }
}
