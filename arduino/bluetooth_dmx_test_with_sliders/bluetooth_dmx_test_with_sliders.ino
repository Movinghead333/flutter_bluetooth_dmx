#include <DmxSimple.h>

void setup(){
 Serial.begin(9600);  //serieller Monitor wird gestartet, Baudrate auf 9600 festgelegt
 pinMode(13,OUTPUT);  //PIN 13 wird als Ausgang festgelegt
 DmxSimple.usePin(4);
}
char channel = 0;
char channelValue = 0;

bool readingChannel = true;
 
void loop(){
  // Wait until two bytes are ready in serial buffer
  if(Serial.available() >= 2){
    // Read channel number
    channel = Serial.read();
    // Read channel value
    channelValue = Serial.read();

    // Write the channel value to the selected dmx-channel
    DmxSimple.write((int)channel, (uint8_t)channelValue);
  }
}
