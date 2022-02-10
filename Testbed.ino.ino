#include <Servo.h>

Servo myservo;  // create servo object to control a servo
// twelve servo objects can be created on most boards

float t = 0; // time
float fp = 0.2333; // pulmonar frequency
float fc = 1.1666; // cardiac frequency

int posC = 0; // store cardiac servo position
int posP = 0; // store pulmonar servo position
int pos = 0;    // variable to store the servo position

void setup() {
  myservo.attach(9);  // attaches the servo on pin 9 to the servo object
}

void loop() {
    t += 0.01;
    posC = 15*cos(2*3.141592*fc*t);
    posP = 70*cos(2*3.141592*fp*t);
    pos = posC+posP+90;
    myservo.write(pos);              // tell servo to go to position in variable 'pos'
    delay(10);                       // waits 10ms for the servo to reach the position
}
