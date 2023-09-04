#include <Wire.h>
 
byte RxByte;
 
void I2C_RxHandler(int numBytes)
{
  while(Wire.available()) {  // Read Any Received Data
    char c = Wire.read();    // Receive a byte as character
    Serial.println(c, HEX);         // Print the character
  }
}
 
void setup() {
  Wire.begin(0x66); // Initialize I2C (Secondary Mode: address=0x66 )
  Wire.onReceive(I2C_RxHandler);
  Serial.begin(31250);
}
 
void loop() {
  // Nothing To Be Done Here
}