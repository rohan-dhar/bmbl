/*
  
  PIS PROJECT 1;
  
  TEAM MEMBERS:
    ROHAN DHAR - 2019443
    PRAKHAR PRASAD - 2019
    SACHLEEN KAUR - 2019
   
   CREDITS:
     AUDIO FILES EFFECTS: https://www.zapsplat.com/
     MAIN BACKGROUND AUDIO: https://www.youtube.com/watch?v=_hbnMgHgZfs

*/

import processing.serial.*;
import processing.sound.*;

// Core Constants and settings
final int screenWidth = 1200, 
  screenHeight = 800, 
  blockSize = 66, 
  colorsNum = 7, 
  playerSize = 180, 
  playerMaxX = 220, 
  playerColorsNum = 9;

final color RED = color(255, 138, 133), 
  GREEN = color(46, 204, 170), 
  BLUE = color(110, 187, 255), 
  YELLOW = color(238, 221, 85), 
  PURPLE = color(160, 150, 255), 
  CYAN = color(90, 230, 235), 
  ORANGE = color(255, 160, 70);

final String menuOptions[] = {
  "Single player with Controller", 
  "Single player with Motion", 
  "Two player with Motion and Controller"
};

final color COLORS[] = {RED, GREEN, BLUE, YELLOW, PURPLE, CYAN, ORANGE};
final String gameName = "Bmbl";
float blockProbability = 0.04, speed = 5;

PFont avenirBold, avenir;

Audio bgAudio, blockAudio, undoAudio, undoFailAudio;

// Basic Data 
Floor floor;
Player player1 = new Player(playerSize, playerMaxX, screenWidth, screenHeight, playerColorsNum, 1);
Player player2 = new Player(playerSize, playerMaxX, screenWidth, screenHeight, playerColorsNum, 2);

BlockManager blocks = new BlockManager(blockSize, screenWidth);

Arduino a1, a2;

Game game;

void setup() {

  bgAudio = new Audio(this, "bg.wav");
  blockAudio = new Audio(this, "block.mp3");
  undoAudio = new Audio(this, "undo.mp3");
  undoFailAudio = new Audio(this, "undoFail.mp3");
  
  bgAudio.loop();

  
  size(1200, 800);
  smooth();
  noStroke();

  floor = new Floor("bg1.jpg", screenWidth, screenHeight);
  avenirBold = createFont("AvenirNext-Bold", 18);
  
  textFont(avenirBold);

  //a2 = new Arduino(this, 1, 1, 1);
  a2 = new Arduino(this, 2, 40, 40);
  
  Element splashScreen = new Element("splash.jpg", 0, 0, screenWidth, screenHeight);


  game =  new Game(gameName, menuOptions, screenWidth, screenHeight, player1, player2, blocks, floor, playerColorsNum, speed, blockProbability, a1, a2, splashScreen, blockAudio, undoAudio, undoFailAudio);  
  game.setState(0);
}

void draw() {
  game.floor.render();
  game.floor.next(speed);
  
  if (game.state == 0) {
    game.renderPage();
  } else if (game.state == 1 || game.state == 2 || game.state == 5) {
    game.next();
  } else if (game.state == 3 | game.state == 4 || game.state == 6 | game.state == 7) {
    game.renderPage();
  }
}

void keyPressed() {
  game.handleKeyPress();
}
