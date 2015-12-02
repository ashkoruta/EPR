#define SERVO_PIN         3  // Any pin on the Arduino or Gertboard will work.

void setup()
{
  pinMode(SERVO_PIN, OUTPUT);
}

// 50 degrees = 1 + 50/180 ms
int period = 25 * 1000; // 25 milliseconds (ms)
int zeroDegrees = 1 * 1000; // 1 ms is 0 degrees
int target =  zeroDegrees + 50000/180; // X ms for 50deg
void loop()
{
 	digitalWrite(SERVO_PIN, HIGH);
 	// Delay for the length of the pulse
        delayMicroseconds(target);
        // Turn the voltage low for the remainder of the pulse
        digitalWrite(SERVO_PIN, LOW);
        // Delay this loop for the remainder of the period so we don't
        // send the next signal too soon or too late
        delayMicroseconds(period - target);
}