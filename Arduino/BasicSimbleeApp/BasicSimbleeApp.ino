#include <SimbleeBLE.h>

#define LED     2
#define BUTTON  3

bool bConnected = false; // state of BLE connectivity; true: connected to master, false: advertising or off
bool bPressed   = false; // state of the button; true: pressed, false: released

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);

  pinMode(LED, OUTPUT);
  pinMode(BUTTON, INPUT); // external pullup

  digitalWrite(LED, LOW);

  // setup Simblee advertisement info
  SimbleeBLE.deviceName = "Basic Simblee";
  SimbleeBLE.customUUID = "1234"; // hex as a char string
  SimbleeBLE.advertisementInterval = 200;
  SimbleeBLE.txPowerLevel = 4;
  SimbleeBLE.connectable = true;

  bConnected = false;
  bPressed = false;
  
  // start the BLE stack
  SimbleeBLE.begin();
}

void loop() {
  // only do something when the Simblee is connected to a master
  if (bConnected) {
    if (!digitalRead(BUTTON) && !bPressed) {
      sendState(1);
    } else if (digitalRead(BUTTON) && bPressed) {
      sendState(0);
    }
  }
}

void SimbleeBLE_onAdvertisement(bool start) {
  if (start) {
    Serial.println("Advertising started");
  } else {
    Serial.println("Advertising ended");
  }
}

void SimbleeBLE_onConnect() {
  Serial.println("Connected!");
  bConnected = true;
}

void SimbleeBLE_onDisconnect() {
  Serial.println("Disconnected");
  bConnected = false;
}

void sendState(int state) {
  delay(50);
  SimbleeBLE.sendInt(state);
  bPressed = state;
}

void SimbleeBLE_onReceive(char *data, int len) {

  Serial.print("received: ");
  for (int i=0; i<len; i++) {
    int temp = data[i];
    Serial.print(temp);
    Serial.print(" ");
  }
  Serial.println();
  
  int control = data[0];
  // toggle LED
  if (control == 0) {
    digitalWrite(LED, LOW);
  } else if (control == 1) {
    digitalWrite(LED, HIGH);
  }
}

