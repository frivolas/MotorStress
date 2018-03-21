////////////////////////////////////////////////////////////////////////
// Motor Stressor
// By Oscar Frias (@_frix_) 2017
// www.OscarFrias.com
//
// For this to work OK, do the following:
//   - Plug the Arduino first
//   - Then Plug the TinyG
//   - Dump the INIT file with Tinyterm or other, then close that connection
//   - Come back to this app, run it.
//
//
////////////////////////////////////////////////////////////////////////



import processing.serial.*;
import controlP5.*;

// GUI
ControlP5 cp5;

// Serial variables
Serial myArduino;
Serial myTinyG;
int serialCount=0;
boolean firstContact = false;

// misc variables
float textXpos = 0;
float textYpos = 0;
float textWidth = 35;
float pad = 40;
float labelYpos = 0;
PFont font;
long cC=14345;    //click counter

// File variables
String theHeader = "Time, Move Sent, Button Pressed, Counter";
String theFile;
PrintWriter output;

// GCode commands to send.
String gStop = "!% \n";
String gBack = "G91 G1 A-5 F1500\n";
String gPush = "G91 G1 A20 F75\n";
String firstPush = "G91 G1 A100 F100 \n";

void setup()
{
  size(650,400);
  background(255);
  font = createFont("arial",20);
  startGUI();
  printArray(Serial.list());
  myArduino = new Serial(this, Serial.list()[0], 115200);
  myTinyG = new Serial(this, Serial.list()[1], 115200);
  
  theFile = thePath();
  output = createWriter(theFile);
  output.println(theHeader);
  
  textXpos = width/6;
  textYpos = height-50;
  labelYpos = height - height + 65; 

}


void draw()
{
  background(255);
  textSize(20);
  fill(0);
  text("DIWire Motor Stressor", textXpos-80, 30);
  
  textSize(100);
  text("Rep: " + cC, textXpos-80,height/2);
  textSize(10);
  fill(0);
  text("Press ESC to quit and save the data to: \n" + theFile, textXpos-90, height-20);
  textSize(12);
  text(theTime(),width-80, height - 15);
  
}


void serialEvent(Serial thisPort) {
  // read a byte from the serial port:
  int inByte = thisPort.read();
  print(char(inByte));
  if(inByte >0){
    if(thisPort == myArduino){
  // if this is the first byte received, and it's an A,
  // clear the serial buffer and note that you've
  // had first contact from the microcontroller. 
  // Otherwise, add the incoming byte to the array:
  if (firstContact == false) {
    if (inByte == 'A') { 
      myArduino.clear();            // clear the serial port buffer
      firstContact = true;          // you've had first contact from the microcontroller
      myArduino.write('R');         // Reply for complete handshake
      myTinyG.write("$4pm=1 \n");
    }
  } else {
    if(inByte == 'P'){
      // We're pushing the button. Count the click, then stop and retreat.
      myTinyG.write(gStop);
      delay(50);
      cC++;
      myTinyG.write("G28.3A0 \n");
      delay(50);
      myTinyG.write(gBack);
      println("Got button");
      delay(10);
      
      // print the values to the terminal and to the file
      println(theTime() + "\t Y \t Y");
      output.println(theTime() + ",Y,Y,"+cC );
      output.flush();
      
      // All clear and click recorded
      // Wait 1.5sec and send the push again
      delay(1250);
      myTinyG.write("$4pm=0 \n");
      println("$4pm=0");
      long millispre = millis();
      println("going into delay");
      delay(2000);
      long millisout = millis() - millispre;
      println("coming out of delay = " + millisout);
      
      myTinyG.write("$4pm=1 \n");
      println("$4pm=1");
      delay(100);
      //Send move to motor
      myTinyG.write(gPush);
      delay(50);
      println("Move Sent");
    }
   }
    }
  }
}





String theDate(){
  String theMinute, theSec;
  int y = year();
  int mo = month();
  int d = day();
  int h = hour();
  int mi = minute();
  int s = second();

  if(mi<10) theMinute = "0" + mi;
  else theMinute = "" + mi;

  if(s<10) theSec = "0" + s;
  else theSec = "" + s;

  String dateString = y + "" + mo + "" + d + "-" + h + theMinute + theSec;

  return dateString;
}


String theTime(){
  String theMinute, theSec;
  int h=hour();
  int mi=minute();
  int sec = second();
  
  if(mi<10) theMinute = "0" + mi;
  else theMinute = "" + mi;

  if(sec<10) theSec = "0" + sec;
  else theSec = "" + sec;

  //String timeString = "[" + h + ":" + theMinute + ":" + theSec + "] ";
  String timeString = h + ":" + theMinute + ":" + theSec;
  return timeString;
}

String thePath(){
 String fileName = dataPath("") + theDate() + ".csv";
 return fileName;
}

void keyPressed(){
  if(key == ESC){
    fill(255);
    stroke(0);
    rect(width/4,height/4,width/2,height/4);
    fill(0);
    textSize(25);
    text("Saving Log file, \ndon't close this window",width/4+25,height/4+40);
    println("SAVING FILE!");
    output.flush();
    output.close();

    exit();
  }
}


public void Start(){
  // Get the command from the text field
  println("Starting test");
  // Put the command on the terminal
  myTinyG.write(gBack);
  delay(50);
  myTinyG.write(firstPush);     // Since this is the very first time, let's start by pushing slowly
}



public void Stop(){
  // Get the command from the text field
  println("Stopping test");
  // Put the command on the terminal
  myTinyG.write("!% \n");
}



// Let's work on the GUI
void startGUI(){
  // Construct a CP5
  cp5 = new ControlP5(this);            // start the cp5 GUI
  
    // create a new button with name 'Send' to shoot the command to the tinyG
  cp5.addBang("Start")
  .setPosition(width-180,height-100)
  .setSize(60,40)
  .setColorBackground(color(0,214,116))
  .setColorActive(color(0,214,116))
  .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
  ;

  
    // create a new button with name 'Send' to shoot the command to the tinyG
  cp5.addBang("Stop")
  .setPosition(width-100,height-100)
  .setSize(60,40)
  .setColorBackground(color(180,40,50))
  .setColorActive(color(180,40,50))
  .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
  ;
  
}