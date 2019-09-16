#include <MPU6050.h>
#include <SoftwareSerial.h>

const int ledPin = 8,
          vibPin = 3,
          touchPin = A0,
          rxPin = 6,
          txPin = 7,
          gyroTolerance = 8,
          touchTolerance = 40;

const float gyroDeSen = 3;

MPU6050 gyro;

SoftwareSerial bt(rxPin, txPin);

bool buzzing = false;
int buzzFor = -1;
unsigned long int buzzStart = 0;

float x = 0, y = 0;

int colonCount(String s) {
  int cnt = 0;
  char c;  
  for (int i = 0; i < s.length(); i++) {
    c = s[i];
    if (c == ':'){
      cnt++;
    }
  }
  return cnt;
}

void processInstruction(String ins) {
  String code = ins.substring(0, 3);
  if (code == "LON") {
    digitalWrite(ledPin, HIGH);
  } else if (code == "LOF") {
    digitalWrite(ledPin, LOW);
  } else if (code == "BUZ") {
    buzzing = true;
    buzzFor = ins.substring(3).toInt();
    buzzStart = millis();
  } else if (code == "DBG") {
    bt.println(buzzing);
    bt.println(buzzStart);
    bt.println(buzzFor);
  }
}

void buzzCheck() {
  if (!buzzing) {
    return;
  }
  if (millis() - buzzStart <= buzzFor) {
    digitalWrite(vibPin, HIGH);
  } else {
    digitalWrite(vibPin, LOW);
    buzzing = false;
    buzzFor = -1;
    buzzStart = -1;
  }
}

String getRes(float x, float y, bool undo) {
  String res = "";
  res += (int)x;
  res += ':';
  res += (int)y;
  res += ':';
  res += (int)undo;
  return res;
}

void setup() {
  gyro.begin(MPU6050_SCALE_2000DPS, MPU6050_RANGE_2G);
  gyro.calibrateGyro();

  pinMode(ledPin, OUTPUT);
  pinMode(touchPin, INPUT);
  pinMode(vibPin, OUTPUT);
  
  bt.begin(115200);
  Serial.begin(2000000);
}

void loop() {
  bool undo = false;

  delay(100);
  buzzCheck();
  if (Serial.available()) {
    String ins;
    ins = Serial.readStringUntil('\n');
    processInstruction(ins);
  }
  
  
//  if(analogRead(touchPin) > touchTolerance){
//    undo = true;
//  }
  
  Vector rotation = gyro.readNormalizeGyro();
  if (rotation.XAxis < gyroTolerance  && rotation.XAxis > -gyroTolerance ) {
    x = 0;
  } else {
    x = (float)rotation.XAxis/gyroDeSen;
  }
  if (rotation.YAxis < gyroTolerance  && rotation.YAxis > -gyroTolerance ) {
    y = 0;
  } else {
    y = (float)rotation.YAxis/gyroDeSen;
  }

  String resp = getRes(x, y, undo);
  if (resp.length() < 5 || colonCount(resp) != 2) {
    resp = "0:0:0";
  }
  bt.println(resp);
  Serial.println(resp);
  
  delay(20);
}
