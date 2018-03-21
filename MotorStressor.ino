////////////////////////////////////////////////////////////////////////
// MotorStressor to Serial
// By Oscar Frias (@_frix_) 2017
// www.OscarFrias.com
//
// Very Simple program that sends a char via serial every time a button is pressed on pin#2
//
// The purpose is to have a "very long" Motor Stress Test without constant operator supervision.
// One of the DIWire Moons PL23HSAP4300-4AG motors is commanded to rotate a determined amount
// at a given speed for max torque. The motor has a torque arm connected to the output shaft,
// and this arm presses on a pushrod. The pushrod then presses on the button read by this script,
// telling the Processing sketch to revert motion and repeat. 
//
// Therefore, this sketch takes the role of test supervisor.
//
// The pushrod only presses the button if the arm is able to defeat a 25lb/in spring, so that the motor
// is stressed to about 85% of its peak torque. The purpose of this test is to stress the motor and
// determine durability. This test was devised due to the motor-gearbox coupler failures of July 2017.
//
// On the other end, a Processing sketch will read the char sent by this sketch and send a move to a tinyG.
//
// Thanks to the Arduino Playground for the examples.
////////////////////////////////////////////////////////////////////////

// Define button pin
#define button 2
#define LED 13

// Serial byte in
int inByte = 0;
int bState=0;
int lastBState=LOW;
int ledState=HIGH;

// The button will be debounced to prevent errors
long lastDebounceTime=0;
long debounceDelay=25;
long counter=0;

void setup() {
  // Start the Serial
  Serial.begin(115200);
  delay(100);
  establishContact(); // Send handshake to Processing
  
  pinMode(button,INPUT_PULLUP);
  pinMode(LED,OUTPUT);
  digitalWrite(LED,LOW);
}



void loop() {
  // DEBOUNCE BLOCK
  int reading = digitalRead(button);
  if (reading != lastBState) {
    // reset the debouncing timer
    lastDebounceTime = millis();
  }
  if ((millis() - lastDebounceTime) > debounceDelay) {
  // if the button state has changed:
    if (reading != bState) {
      bState = reading;

      // ACTION BLOCK. BUTTON IS NC, SO 
      // ONLY ACT IF STATE IS LOW
      if (bState == LOW) {
        Serial.write("P");        // tell processing that the button was pressed
        ledState = !ledState;
        counter++;
        Serial.println(counter);  // for debugging

      }
    }
  }
  // set the LED:
  digitalWrite(LED, ledState);
  // save the reading.  Next time through the loop,
  // it'll be the lastButtonState:
  lastBState = reading;
}


// Let's handshake with processing.
// Send a char until they reply
void establishContact(){
  while(Serial.available() <= 0){
    Serial.write("A");
    delay(250);
  }
}

