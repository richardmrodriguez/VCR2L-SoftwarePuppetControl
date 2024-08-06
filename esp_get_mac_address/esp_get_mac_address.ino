#include <esp_now.h>
#include <WiFi.h>
#include <esp_wifi.h>



void setup() {
  Serial.begin(115200);
  Serial.println(WiFi.macAddress());
}

void loop() {
  // put your main code here, to run repeatedly:

}
