#include <IRremote.h>

const int irPin = 7,
          ledPin = 8,
          vibPin = 3,
          toneHz = 1970;



// UP, DOWN, LEFT, RIGHT, UNDO
unsigned long int dir[5] = {0xFF18E7, 0xFF4AB5, 0xFF10EF, 0xFF5AA5, 0xFF38C7};

IRrecv ir(irPin);
decode_results irRes;

void processInstruction(String ins){
  String code = ins.substring(0, 3);
  if(code == "LON"){
    digitalWrite(ledPin, HIGH);
  }else if(code == "LOF"){
    digitalWrite(ledPin, LOW);
  }else if(code == "BUZ"){
//    buzzing = true;
//    buzzFor = ins.substring(3).toInt();
//    buzzStart = millis();
      tone(vibPin, toneHz, ins.substring(3).toInt());
  }
}

int getDir(long int c){
  if(c == 0xFFFFFFFF){
    return 5;
  }
  for(int i = 0; i < 5; i++){
    if(dir[i] == c){
      return i;
    }
  }
  return -1;
}

void setup() {

  pinMode(ledPin, OUTPUT);
  pinMode(vibPin, OUTPUT);
  pinMode(irPin, INPUT);  

  ir.enableIRIn();

  Serial.begin(2000000);
}

void loop() {
  if(Serial.available()){
    String ins;
    ins = Serial.readStringUntil('\n');    
    processInstruction(ins);    
  } 
  if (ir.decode(&irRes)) {
    Serial.println(getDir(irRes.value));
    delay(50);
    ir.resume();     
  }
}
