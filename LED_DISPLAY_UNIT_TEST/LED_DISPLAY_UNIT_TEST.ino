#include <SparkFun_I2C_Mux_Arduino_Library.h>

#include <Wire.h>

#include <SparkFun_Alphanumeric_Display.h>

QWIICMUX myMux;

HT16K33 display;

void setup() {
  // put your setup code here, to run once:

  Serial.begin(115200);
  Wire.begin();

  myMux.begin(0x74);
  myMux.enablePort(0);
  if (display.begin(0x70, 0x71, 0x72, 0x73) == false)
  {
    Serial.println("Not connected yet.");
    while(1);
  }
  myMux.disablePort(0);
  
  
  myMux.enablePort(1);
  if (display.begin(0x70, 0x71, 0x72, 0x73) == false)
  {
    Serial.println("Not connected yet.");
    while(1);
  }
  myMux.disablePort(1);

  Serial.println("Connected to displays.");
  //display.initialize();

  //display.setBrightness(15);

}

uint8_t counter = 0;

uint16_t storedDigits[] ={
  0, 0, 0, 0, 
  0, 0, 0, 0,
  0, 0, 0, 0,
  0, 0, 0, 0, 
};

uint16_t previousDigits[] ={
  0, 0, 0, 0, 
  0, 0, 0, 0,
  0, 0, 0, 0,
  0, 0, 0, 0, 
};

void loop() {

  Serial.print("Counter: ");
  Serial.println(counter);

  for (uint8_t c = 0; c < 16; c++)
  {
    storedDigits[c] = bit(random(14));
  }

  for (uint8_t d = 0; d < 16; d++)
  {
    myMux.enablePort(0);
    display.illuminateChar(storedDigits[d], d);
    myMux.disablePort(0);
    myMux.enablePort(1);
    display.illuminateChar(storedDigits[d], d);
    myMux.disablePort(1);
  }
  myMux.enablePort(0);
  display.setBrightness(random(1, 16));
  display.updateDisplay();
  myMux.disablePort(0);

  myMux.enablePort(1);
  display.setBrightness(random(1, 16));
  display.updateDisplay();
  myMux.disablePort(1);

  delay(10);

  myMux.enablePort(0);
  display.clear();
  myMux.disablePort(0);
  myMux.setPort(1);
  display.clear();
  myMux.disablePort(1);

  


  


  if (compareArrays_u16_t(storedDigits, previousDigits) == false)
  {
    copyFromArrayToAnother_u16_t(storedDigits, previousDigits, 16);
    Serial.println("Copying arrays...");
  }

}
 
void incrementSegment(uint8_t digit)
{
  for (uint8_t i = 0; i < 14; i++)
  {
    //display.clear();
    display.illuminateChar(bit(i), digit);
    display.updateDisplay();
  }

}

void turnOffSegments(uint16_t segments, uint8_t digit)
{
  storedDigits[digit] = segments ^ storedDigits[digit];
}

void turnOnSegments(uint16_t segments, uint8_t digit)
{
  storedDigits[digit] = segments | storedDigits[digit];
}

bool compareArrays_u16_t(uint16_t firstArray[], uint16_t secondArray[])
{
  for (int i = 0;  i < 16; i++)
  {
    if(firstArray[i] != secondArray[i]) 
    {
      return false;
    }
    else
    {
      continue;
    }
  }

  return true;
}

void copyFromArrayToAnother_u16_t(uint16_t array1[], uint16_t array2[], uint8_t arraySize)
{
  for (int i = 0;  i < arraySize; i++)
  {
    array2[i] = array1[i];
  }
}
