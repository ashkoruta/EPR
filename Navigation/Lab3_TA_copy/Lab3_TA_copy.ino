/*
2.12 Lab 2: Wheeled Robot Kinematics

Zack Bright - zbright@mit.edu
& Dan Gonzalez - dgonz@mit.edu
& Fangzhou Xia- xiafz@mit.edu
Sept. 2015
*/


//Include the SPI bus library, the encoder buffer library, and the motor shield library
#include "Arduino.h"
#include "SPI.h"
#include "LS7366.h"
#include "DualMC33926MotorShield.h"
#include "ArduinoLab3Helper.h"

#define SERVO_PIN         3  // Any pin on the Arduino or Gertboard will work.

void servoOp(long duty) {
  // 50 degrees = 1 + 50/180 ms
  long period = 25 * 1000; // 25 milliseconds (ms)
  long target =  duty;
  long count = 0;
  while (count < 1200) {
     digitalWrite(SERVO_PIN, HIGH);
    // Delay for the length of the pulse
    delayMicroseconds(target);
    // Turn the voltage low for the remainder of the pulse
    digitalWrite(SERVO_PIN, LOW);
    // Delay this loop for the remainder of the period so we don't
    // send the next signal too soon or too late
    delayMicroseconds(period - target);
    count++;
  }
}

void servoClose()
{
  int period = 25 * 1000;
  int target =  1700;
  long count = 0;
  while (count < 800) {
    digitalWrite(SERVO_PIN, HIGH);
    delayMicroseconds(target);
    digitalWrite(SERVO_PIN, LOW);
    delayMicroseconds(period - target);
    count++;
  }
}

void servoOpen()
{
  int period = 25 * 1000;
  int target =  1200;
  long count = 0;
  while (count < 920) {
    digitalWrite(SERVO_PIN, HIGH);
    delayMicroseconds(target);
    digitalWrite(SERVO_PIN, LOW);
    delayMicroseconds(period - target);
    count++;
  }
}

EncoderMeasurement measureRobot; //instantiate encoder handler class
RobotPosition robotPos; //instantiate robot position and orientation calculation class
PIController moveRobot; //instantiate velocity PI controller class
SerialCommunication reportData; //instantiate matlab plot serial communication class
PathPlanner pathPlanner; //instantiate path planner

void setup() {
  Serial.begin(115200);      // Initialize Serial Communication
  initEncoders();       Serial.println("Encoders Initialized..."); //initialize Encoders
  clearEncoderCount();  Serial.println("Encoders Cleared..."); //clear Encoder Counts
  currentTime = micros(); //initialize timer
  prevTime = micros(); //initialize timer
  measureRobot.initialize(); //initialize robot encoder handler
  robotPos.initialize();//initialize robot position and orientation calculation
  moveRobot.initialize(); Serial.println("Motor Driver Initialized...");//intialize velocity PI controller
  reportData.initialize(); //initialize matlab plot serial communication
  pathPlanner.initialize(); //initialize path planner
  pinMode(SERVO_PIN, OUTPUT);
  
  delay(1e3);// set a delay so the robot doesn't drive off without you

}

void loop() {

  //timed loop implementation
  if (micros() - prevTime >= PERIOD_MICROS) {
    currentTime = micros();
    measureRobot.update(); //check encoder
    robotPos.update(measureRobot.dThetaL, measureRobot.dThetaR); //update position

    reportData.sendSerialData(robotPos); //report data to matlab via serial communication
    reportData.receiveSerialData();
    if (int s = reportData.ServoCom) {
      if (s == 1)
        servoClose();
      else
        servoOpen();
      reportData.ServoCom = 0;
      goto m_end;
    }
    //pathPlanner.LabTestRun(robotPos); //plan the next path
    robotPos.GPSupdate(reportData, pathPlanner);
    pathPlanner.turnToGo(robotPos, reportData); //turn then go straight towards next point
    
    /*
    if (!reportData.finished){
    pathPlanner.desiredMVL = .2;
    pathPlanner.desiredMVR = .2;
    }
    
    pathPlanner.OrientationController(robotPos, reportData);
    if (reportData.finished){
      pathPlanner.desiredMVL = 0.0;
    pathPlanner.desiredMVR = 0.0;
    }
    */
    
    moveRobot.doPIControl("Left", pathPlanner.desiredMVL, measureRobot.mVL); //left motor PI control
    moveRobot.doPIControl("Right", pathPlanner.desiredMVR, measureRobot.mVR); // right motor PI control
m_end:
    prevTime = currentTime; //update timer
   
  }
}




