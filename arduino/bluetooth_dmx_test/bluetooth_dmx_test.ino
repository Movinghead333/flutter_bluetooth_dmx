#include <DmxSimple.h>

char blueToothVal; //Werte sollen per Bluetooth gesendet werden
char lastValue;   //speichert den letzten Status der LED (on/off) 
 
void setup(){
 Serial.begin(9600);  //serieller Monitor wird gestartet, Baudrate auf 9600 festgelegt
 pinMode(13,OUTPUT);  //PIN 13 wird als Ausgang festgelegt
 DmxSimple.usePin(4);
}
 
void loop(){
  if(Serial.available()) //wenn Daten empfangen werden...      
{
    blueToothVal=Serial.read();//..sollen diese ausgelesen werden
  }
  if (blueToothVal=='1') //wenn das Bluetooth Modul eine „1“ empfängt..
  {
    digitalWrite(13,HIGH);   //...soll die LED leuchten
    for (int i = 1; i <= 3; i++) {
      DmxSimple.write(i, 255);
    }
    if (lastValue!='1') //wenn der letzte empfangene Wert keine „1“ war...
      Serial.println(F("LED is on")); //..soll auf dem Seriellen Monitor „LED is on“ angezeigt werden
    lastValue=blueToothVal;
  }
  else if (blueToothVal=='0') //wenn das Bluetooth Modul „0“ empfängt...
  {           
    digitalWrite(13,LOW);  //..soll die LED nicht leuchten
    for (int i = 1; i <= 3; i++) {
      DmxSimple.write(i, 0);
    }
    if (lastValue!='0')  //wenn der letzte empfangene Wert keine „0“ war...
      Serial.println(F("LED is off")); //..soll auf dem seriellen Monitor „LED is off“ angezeigt werden 
    lastValue=blueToothVal;
  }
}
