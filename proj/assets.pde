// Basic Image Elements 
class Element {
  public PImage img;
  public int x, y, w, h;
  public Element(String img, int x, int y, int w, int h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;    

    this.img = loadImage(img);
  }

  public void render() {
    image(this.img, this.x, this.y, this.w, this.h);
  }
};

class Audio{
  SoundFile file;
  public Audio(PApplet app, String fileName){
    this.file = new SoundFile(app, fileName);
  }
  public void loop(){
    this.file.loop(1.0, 0.6);
  }
  public void play(){
    this.file.play();
  }
}

class Arduino {
  int type, moveByX, moveByY, lastMove;
  boolean ledStatus;
  Serial port;

  public Arduino(PApplet app, int type, int moveByX, int moveByY) {
    int cTries = 1, cLimit = 10;

    this.type = type;
    this.moveByX = moveByX;
    this.moveByY = moveByY;
    this.lastMove = -1;
    this.ledStatus = false;

    println("CONNECTING TO PORT: ");
    if(this.type == 1){
      println(Serial.list()[1]);
    }else{
      println(Serial.list()[Serial.list().length - 1]);
    }
    
    
    while (cTries <= cLimit) {
      try {
        if(this.type == 1){
          this.port = new Serial(app, Serial.list()[1], 115200);
        }else{
          this.port = new Serial(app, Serial.list()[Serial.list().length - 1], 2000000);
        }

      }
      catch(Exception e) {
        cTries++;
        continue;
      }
      break;
    }
    if (cTries > cLimit) {
      println("Can't open Serial. Quitting.");
      exit();
    } else {
      print("Connected in " + Integer.toString(cTries) + " tries");
    }
    this.port.clear();
  }

  private int[] getDirToMove(int v) {
    if (v == 0) {
      return new int[] {0, -this.moveByY};
    } else if (v == 1) {
      return new int[] {0, this.moveByY};
    } else if (v == 2) {
      return new int[] {-this.moveByX, 0};
    } else if (v == 3) {
      return new int[] {this.moveByX, 0};
    } else if (v == 4) {
      return new int[] {-1, -1};
    }
    return new int[] {0, 0};
  }

  public int[] getMove() {
    if (this.port.available() == 0) {
      return new int[] {0, 0};
    }
    if (this.type == 2) {
      String data = this.port.readStringUntil('\n');
      if (data == null) {
        return new int[] {0, 0};
      }
      data = data.substring(0, data.length() - 2);
      int v = Integer.parseInt(data);

      if (v == 5 && this.lastMove != -1) {
        int r[] = this.getDirToMove(this.lastMove);
        return r;
      } else {
        this.lastMove = v;
        int r[] = this.getDirToMove(v); 
        return r;
      }
    }else{
      String data = this.port.readStringUntil('\n');
      if (data == null || data == "") {
        return new int[] {0, 0};
      }
      data = data.substring(0, data.length() - 2);
      String spl[] = data.split(":");
      int x = 0, y = 0, undo = 0;
      try{
        x = Integer.parseInt(spl[0]);
        y = Integer.parseInt(spl[1]);
        undo = Integer.parseInt(spl[2]);
      }
      catch(Exception e){
        print("\nCorrupt Arduino Response: \n");
        print("\nString Data: \n");
        println(data);
        print("\nArray Data: \n");
        printArray(spl);
        return new int[] {0, 0};
      }
      if(undo == 1){
        return new int[] {-1, -1};
      }else{
        return new int[] {x, y};
      }
    }    
  }

  public void ledOn() {
    this.ledStatus = true;
    this.port.write("LON\n");
  }

  public void ledOff() {
    this.ledStatus = false;
    this.port.write("LOF\n");
  }

  public void buzz(int msec) {    
    this.port.write("BUZ"+Integer.toString(msec)+"\n");
  }
}

// Floor: Set of multiple tile Elements
class Floor {

  Element bg, bgCopy;
  int screenDelta, screenWidth;

  public Floor(String bgImg, int screenWidth, int screenHeight) {
    this.bg = new Element(bgImg, 0, 0, 0, screenHeight);
    this.bg.w = (int)((float)this.bg.img.width / (float)this.bg.img.height * (float)screenHeight);

    this.bgCopy = new Element(bgImg, 0, 0, 0, screenHeight);
    this.bgCopy.w = (int)((float)this.bg.img.width / (float)this.bg.img.height * (float)screenHeight);

    this.screenWidth = screenWidth;
    this.screenDelta = this.bg.w - screenWidth;
  }

  public void init() {
    this.bg.x = 0;
  }

  public void next(float speed) {
    if (Math.abs(this.bg.x) >= this.bg.w) {
      this.bg.x = 0;
    } else {
      this.bg.x -= speed;
    }
  }

  public void render() {    
    if (-this.bg.x > this.screenDelta) {
      this.bg.render();
      int wid = (-this.bg.x) - this.screenDelta;
      this.bgCopy.x = this.screenWidth - wid;
      this.bgCopy.render();
    } else {
      this.bg.render();
    }
  }
}  

class Player {
  int x, y, size, maxX, screenWidth, screenHeight, undoLeft, colorsNum, number;

  ArrayList <Integer> colors = new ArrayList();
  ArrayList <Integer> colorsToMatch = new ArrayList();

  public Player(int size, int maxX, int screenWidth, int screenHeight, int colorsNum, int n) {
    this.size = size;
    this.maxX = maxX;
    this.screenWidth = screenWidth;
    this.screenHeight = screenHeight;
    this.colorsNum = colorsNum;
    this.number = n;
  }

  public void init() {    
    this.x = this.screenWidth/2;
    if (this.number == 1) {
      this.y = 0;
    } else {
      this.y = this.screenHeight;
    }

    this.undoLeft = 5;
    this.colors.clear();
    this.colorsToMatch.clear();    
    for (int i = 0; i < this.colorsNum; i++) {
      this.colorsToMatch.add( COLORS[(int)random(COLORS.length)] );
    }
    this.colors.add(this.colorsToMatch.get(0));
  }


  public void move(int x, int y) {
    if (x >= this.screenWidth/2 - maxX && x <= screenWidth/2 + maxX) {
      this.x = x;
    } else if (x < this.screenWidth/2 - maxX) {
      this.x = this.screenWidth/2 - maxX;
    } else {
      this.x = this.screenWidth/2 + maxX;
    }

    if (y < 0) {
      this.y = 0;
    } else if (y > this.screenHeight) {
      y = this.screenHeight;
    } else {
      this.y = y;
    }
  }

  public void moveBy(int x, int y) {
    this.move(this.x + x, this.y + y);
  }

  public boolean undo() {
    if (this.undoLeft > 0) {
      if (this.colors.size() == 1) {
        return false;
      }
      this.colors.remove(this.colors.size()-1);
      this.undoLeft--;
      return true;
    }
    return false;
  } 

  public void render() {    
    int r = this.size / this.colors.size();
    stroke(0, 0, 0, 30);
    for (int i = this.colors.size(); i > 0; i--) {
      fill(this.colors.get(i-1));
      ellipse(this.x, this.y, r*i, r*i);
    }

    r = this.size / this.colorsToMatch.size();
    stroke(0, 0, 0, 20);
    if (this.number == 1) {
      for (int i = this.colorsToMatch.size(); i > 0; i--) {
        fill(this.colorsToMatch.get(i-1));
        ellipse(this.size/2 + 50, this.screenHeight - this.size/2 - 50, r*i, r*i);
      }
    } else {
      for (int i = this.colorsToMatch.size(); i > 0; i--) {
        fill(this.colorsToMatch.get(i-1));
        ellipse(this.screenWidth - 50 - this.size/2, this.screenHeight - this.size/2 - 50, r*i, r*i);
      }
    }

    noStroke();
    fill(255, 255, 255, 150);
    textSize(20);
    
    if (this.number == 1) {
      text("UNDO LEFT", 50, 70);
    } else { 
      text("UNDO LEFT", this.screenWidth-180, 70);
    }

    fill(255, 255, 255);
    textSize(34);
    if (this.number == 1) {
      text(((this.undoLeft != 0)?Integer.toString(this.undoLeft):"NONE :("), 50, 115);
    } else {
      text(((this.undoLeft != 0)?Integer.toString(this.undoLeft):"NONE :("), this.screenWidth - 180, 115);
    }
  }

  public int hasWon() {
    if (this.colors.equals(this.colorsToMatch)) {
      return 1;
    } else {
      int incorrect = 0, firstIncorrect = -1;

      for (int i = 0; i < this.colors.size() && i < this.colorsToMatch.size(); i++) {
        if (!this.colors.get(i).equals(this.colorsToMatch.get(i))) {
          if (firstIncorrect == -1) {
            firstIncorrect = i;
          }
          incorrect++;
        }
      }
      if (incorrect > this.undoLeft || ((this.colors.size() - firstIncorrect) > this.undoLeft && firstIncorrect != -1)) {
        return 2;
      } else {
        return 0;
      }
    }
  }
}

class Block {
  color c;
  int x, y, size;

  public Block(color c, int x, int y, int size) {
    this.x = x;
    this.y = y;
    this.c = c;
    this.size = size;
  }

  public void render() {
    fill(this.c);
    ellipse(this.x, this.y, this.size, this.size);
  }
}

class BlockManager {


  int blockSize, screenWidth; 
  ArrayList<Block> blocks = new ArrayList();

  public BlockManager(int blockSize, int screenWidth) {
    this.blockSize = blockSize;
    this.screenWidth = screenWidth;
  }

  public void add(color c, int y) {
    Block b = new Block(c, this.screenWidth + this.blockSize/2, y, this.blockSize);
    this.blocks.add(b);
  }

  public void next(float speed) {
    for (int i = 0; i < this.blocks.size(); i++) {
      Block b = this.blocks.get(i);
      if (b.x < -b.size/2) {
        this.blocks.remove(i);
      } else {
        b.x -= speed;
        this.blocks.set(i, b);
      }
    }
  }

  public void init() {
    this.blocks.clear();
  }

  public color detectCollision(int x, int y, int playerSize) {
    for (int i = 0; i < this.blocks.size(); i++) {
      Block b = blocks.get(i);
      float dist = (b.x - x)*(b.x - x) + (b.y - y)*(b.y - y);
      dist = (float)Math.sqrt(dist);
      if (dist <= (playerSize/2 + b.size/2)) {
        this.blocks.remove(i);
        return b.c;
      }
    }
    return color(0, 0, 0);
  }

  public void render() {
    for (int i = 0; i < this.blocks.size(); i++) {
      this.blocks.get(i).render();
    }
  }
};



class Game {
  String name, menuOptions[];
  int screenWidth, screenHeight, state, playerColorsNum;
  float speed, blocksProbability;
  Element splashScreen;
  Arduino a1, a2;
  Audio blockAudio, undoAudio, undoFailAudio;

  Player player1, player2;
  Floor floor;
  BlockManager blocks;

  public Game(String name, String[] options, int screenWidth, int screenHeight, Player player1, Player player2, BlockManager blocks, Floor floor, int playerColorsNum, float speed, float blocksProbability, Arduino a1, Arduino a2, Element splashScreen, Audio blockAudio, Audio undoAudio, Audio undoFailAudio) {
    this.state = 0;
    this.name = name;
    this.menuOptions = options;
    this.screenWidth = screenWidth;
    this.screenHeight = screenHeight;
    this.player1 = player1;
    this.player2 = player2;
    this.blocks = blocks;
    this.floor = floor;    
    this.playerColorsNum = playerColorsNum;
    this.speed = speed;
    this.blocksProbability = blocksProbability;
    this.a1 = a1;
    this.a2 = a2;
    this.splashScreen = splashScreen;
    this.blockAudio = blockAudio;
    this.undoAudio = undoAudio;
    this.undoFailAudio = undoFailAudio;
  }
  public void renderPage() {
    textAlign(CENTER, CENTER);
    fill(255, 255, 255);
    if(this.state == 0){      
      this.splashScreen.render();
    }else if (this.state == 3) {  
      textSize(90);
      text("YOU WON", this.screenWidth/2, this.screenHeight*0.45);
      fill(255, 255, 255, 150);
      textSize(36);
      text("Press M to see the Main Menu", this.screenWidth/2, this.screenHeight*0.58);
    }else if (this.state == 4) {
      textSize(90);
      text("GAME OVER :(", this.screenWidth/2, this.screenHeight*0.45);
      fill(255, 255, 255, 150);
      textSize(36);
      text("Press M to see the Main Menu", this.screenWidth/2, this.screenHeight*0.58);
    }else if (this.state == 6) {
      textSize(90);
      text("PLAYER 2 WON!", this.screenWidth/2, this.screenHeight*0.45);
      fill(255, 255, 255, 150);
      textSize(36);
      text("Press M to see the Main Menu", this.screenWidth/2, this.screenHeight*0.58);
    }else if (this.state == 7) {
      textSize(90);
      text("PLAYER 1 WON!", this.screenWidth/2, this.screenHeight*0.45);
      fill(255, 255, 255, 150);
      textSize(36);
      text("Press M to see the Main Menu", this.screenWidth/2, this.screenHeight*0.58);
    }
  }

  public void setState(int state) {        
    int prevState = this.state;
    this.state = state;
    if (state == 1 || state == 2) {      
      textAlign(LEFT);
      if(state == 1){
        this.a2.buzz(1000);
        this.a2.ledOn();
      }
      this.floor.init();
      this.blocks.init();
      this.player1.init();
    }else if (state == 5) {
      textAlign(LEFT);
      this.floor.init();
      this.blocks.init();
      this.player1.init();
      this.player2.init();
      this.a2.buzz(1000);
      this.a2.ledOn();
    }else if (state == 3 || state == 4 || state == 6 || state == 7 || state == 0) {
      this.renderPage();
      if(prevState == 1 || prevState == 5){
        this.a2.buzz(1000);
        this.a2.ledOff();
      }
    }
  }  

  public void next() {
    if (random(1) <= this.blocksProbability) {
      color c = COLORS[(int)random(COLORS.length)];
      int y = (int)random(this.blocks.blockSize/2, this.screenHeight - this.blocks.blockSize/2);
      this.blocks.add(c, y);
    }

    this.blocks.next(speed*2);
    this.blocks.render();
    
    if (this.state == 1 || this.state == 2) {
      int move[];
      if (this.state == 1) {
        move = this.a2.getMove();
      } else {
        move = new int[] {mouseX - this.player1.x, mouseY - this.player1.y};
      }

      if (move[0] == -1 && move[1] == -1 && this.state == 1) {  
        if(!player1.undo()){
          this.a2.buzz(230);
          fill(color(255,255,255, 70));
          rect(0, 0, this.screenWidth, this.screenHeight);
          this.undoFailAudio.play();
        }else{
          this.undoAudio.play();
        }
      } else {
        this.player1.moveBy(move[0], move[1]);        
      }    

      this.player1.render();  
      color col = this.blocks.detectCollision(player1.x, player1.y, player1.size);

      if (col != color(0, 0, 0)) {
        this.player1.colors.add(col);
        if(this.state == 1){
          this.a2.buzz(180);
        }
        this.blockAudio.play();
        int playerState = player1.hasWon(); 
        if (playerState == 1) {
          this.setState(3);
        } else if (playerState == 2) {
          this.setState(4);
        }
      }
    }else{      
      int move1[], move2[];

        move1 = this.a2.getMove();
        move2 = new int[] {mouseX - this.player2.x, mouseY - this.player2.y};

      if (move1[0] == -1 && move1[1] == -1) {
        if(!player1.undo()){
          this.a2.buzz(230);
          fill(color(255,255,255, 70));
          rect(0, 0, this.screenWidth, this.screenHeight);
          this.undoFailAudio.play();
        }else{
          this.undoAudio.play();
        }
      } else {
        this.player1.moveBy(move1[0], move1[1]);
      }    
      
      this.player2.moveBy(move2[0], move2[1]);      
      this.player1.render();  
      this.player2.render();
      
      color col2 = this.blocks.detectCollision(player2.x, player2.y, player2.size);
      color col1 = this.blocks.detectCollision(player1.x, player1.y, player1.size);

      if (col2 != color(0, 0, 0)) {
        this.player2.colors.add(col2);
        this.blockAudio.play();
        int playerState = player2.hasWon(); 
        if (playerState == 1) {
          this.setState(6);
        } else if (playerState == 2) {
          this.setState(7);
        }
      }
      
      if (col1 != color(0, 0, 0)) {
        this.player1.colors.add(col1);
        this.blockAudio.play();
        this.a2.buzz(100);
        int playerState = player1.hasWon(); 
        if (playerState == 1) {
          this.setState(7);
        } else if (playerState == 2) {
          this.setState(6);
        }
      } 
    }
  }

  void handleKeyPress() {
    if (this.state == 0) {
      if (key == '1') {
        this.setState(1);
      }else if (key == '2') {
        this.setState(2);
      }else if (key == '3') {
        this.setState(5);
      }
    } else if (this.state == 2) {
      if (key == ' ') {
        this.player1.undo();
      }
    } else if (this.state == 5) {
      if (key == ' ') {
        this.player2.undo();
      }
    } else if (this.state == 3 || this.state == 4 || this.state == 6 || this.state == 7) {
      if (key == 'm' || key == 'M') {
        this.setState(0);
      }
    }
  }
}
