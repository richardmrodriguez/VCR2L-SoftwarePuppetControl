#include <Adafruit_PWMServoDriver.h>
#include <SparkFun_Alphanumeric_Display.h>
#include <Wire.h>

#include <esp_now.h>
#include <WiFi.h>

#define CHANNEL 1
HT16K33 display;
Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver();

uint8_t ESP_GRN_ADDR[6] = {0xc8, 0xf0, 0x9e, 0x33, 0xc5, 0x38};
uint8_t this_mac_address[6];

uint8_t myData[12];

//uint8_t myStatus* = &myData[0]; // Single status byte, tells us what kind of update

uint8_t myDisplayData[10]; // note, velocity, and the 8 bytes for the 4 digits
uint8_t myServoData[3]; // 3 bytes, 1 per servo

int comparison;

unsigned long deltaTime = millis();
uint16_t prev_message_counter = 0;
volatile uint16_t message_counter = 1;

const int UPDATE_TYPES[] = {
  0b00010000, // SEGMENTS
  0b00110000, // FACE_PANEL
  0b01110000, // LED_EFFECT
  0b11110000, // AMBULATION MOTORS
};

char NOTE_SEGMENT_LUT[] = {
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'J',
  'K',
  'I',
  'L',
  'M',
  'N',
};

void print_mac_address(uint8_t mac[6]){
  Serial.print("MAC: ");
  Serial.print(mac[5],HEX);
  Serial.print(":");
  Serial.print(mac[4],HEX);
  Serial.print(":");
  Serial.print(mac[3],HEX);
  Serial.print(":");
  Serial.print(mac[2],HEX);
  Serial.print(":");
  Serial.print(mac[1],HEX);
  Serial.print(":");
  Serial.println(mac[0],HEX);
}

void setup() {
  Serial.begin(115200);
  //Set device in STA mode to begin with
  WiFi.macAddress(this_mac_address);
  comparison = memcmp(this_mac_address, ESP_GRN_ADDR, sizeof(ESP_GRN_ADDR));

  print_mac_address(this_mac_address);
  print_mac_address(ESP_GRN_ADDR);
  WiFi.mode(WIFI_STA);
  Wire.begin();
  if (display.begin(0x70) == false)
  {
    //Serial.println("Device did not acknowledge! Freezing.");
    while(1);
  }

  // Init ESPNow with a fallback logic
  InitESPNow();
  esp_now_register_recv_cb(OnDataRec);

}

void loop() {
  if (message_counter != prev_message_counter){
    
    handle_status_updates(myData[0]);
    
    for (int i = 0; i < sizeof(myData); i++){
    Serial.print(myData[i], HEX);
    Serial.print(" | ");
    }
    Serial.println(" ");
    prev_message_counter = message_counter;
  }
  
}

void illuminate_segments_from_bytes(uint8_t bytes[]){
  int new_ints[4];


  for (int digit = 0; digit < 4; digit++){
    int n1 = bytes[0 + (digit * 2)];
    int n2 = bytes[1 + (digit * 2)];
    n1 = 0b0000000011111111 & n1;
    int concat_int = n1 | n2 << 8;
    new_ints[digit] = concat_int;
  }

  for (int digit = 0; digit < 4; digit++){
    for (int i = 0; i < 14; i++){
        if (bitRead(new_ints[digit], i) == 1){
          display.illuminateSegment(NOTE_SEGMENT_LUT[i], digit);
      }
    }
  }
  
  


}

bool is_valid_status_byte(uint8_t serial_byte) {

  if (serial_byte > 15){
    
    return true;
  }
  else {
    return false;
  }
}

bool is_data_in_array(int array[], int data){
  for (int i = 0; i < 2; i++) {
      if (array[i] == data) {
          return true;
      }
  }
  return false;
}

void handle_display_updates(){
  uint8_t display_bytes[8] = {};
  for (int i = 0; i < 8; i++){
    display_bytes[i] = myData[i+1];
  }

  char vel_byte = myData[9];
  char channel_byte = myData[10];

  

  if ((comparison == 0) && (channel_byte < 1)){
    Serial.print("Comparison value: ");
    Serial.println(comparison);
    Serial.println("This is green.");
    Serial.print("Velocity: ");
    Serial.println(vel_byte, DEC);

    display.clear();
    display.setBrightness(map(vel_byte, 0, 127, 0, 15));
    illuminate_segments_from_bytes(display_bytes);
  }
  else if (channel_byte >= 1 && comparison != 0){
    Serial.println("This is Blue.");

    display.clear();
    display.setBrightness(map(vel_byte, 0, 127, 0, 15));
    illuminate_segments_from_bytes(display_bytes);
  }

  
  
  display.updateDisplay();
}

void handle_led_effect(){

}

void handle_servo_updates(){

  int control = myData[1];
  int change = myData[2];

  pwm.setPWM(control, 0, angleToPulse(change));

}

void handle_status_updates(int serial_byte) {
  switch (serial_byte) {
    case 16:
      Serial.println("Display update.");
      handle_display_updates();
    //case 0xf0:
    //  handle_servo_updates();
    //case 0b0111_0000:
    //  handle_led_effect();
  }
}
  
int angleToPulse(int angle){
  int maxAngle = 127;
  angle = constrain(angle, 60, 65);
  return map(angle, 0, maxAngle, 490, 75);
}

// Init ESP Now with fallback
void InitESPNow() {
  WiFi.disconnect();
  if (esp_now_init() == ESP_OK) {
    Serial.println("ESPNow Init Success");
  }
  else {
    Serial.println("ESPNow Init Failed");
    // Retry InitESPNow, add a counte and then restart?
    // InitESPNow();
    // or Simply Restart
    ESP.restart();
  }
}

void OnDataRec(const uint8_t *mac_addr, const uint8_t *data, int data_len) {
  deltaTime = millis();
  

  if (is_valid_status_byte(data[0])){
    memcpy(&myData, data, data_len);
    if (message_counter == prev_message_counter){
      message_counter += 1;
      
    }
    
  }


  
}
