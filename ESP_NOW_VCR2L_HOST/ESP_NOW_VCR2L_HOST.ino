#include <esp_now.h>
#include <WiFi.h>

esp_now_peer_info_t client1;
esp_now_peer_info_t client2;
#define CHANNEL 1

uint8_t ESP_GRN_ADDR[] = {0xc8, 0xf0, 0x9e, 0x33, 0xc5, 0x38};

uint8_t ESP_BLU_ADDR[] = {0x64, 0xb7, 0x8, 0xce, 0x7f, 0x24};

const int UPDATE_TYPES[] = {
  0b00010000, // SEGMENTS
  0b00110000, // FACE_PANEL
  0b01110000, // LED_EFFECT
  0b11110000, // AMBULATION MOTORS
};


void setup() {
  Serial.begin(115200);
  //Set device in STA mode to begin with
  WiFi.mode(WIFI_STA);
  // This is the mac address of the Master in Station Mode
  Serial.print("STA MAC: "); Serial.println(WiFi.macAddress());
  Serial.print("STA CHANNEL "); Serial.println(WiFi.channel());
  // Init ESPNow with a fallback logic
  InitESPNow();
  esp_now_register_send_cb(OnDataSent);

  // Add Client1, Betty

  memcpy(client1.peer_addr, ESP_GRN_ADDR, 6);
  client1.channel = 0;
  client1.encrypt = false;

  if (esp_now_add_peer(&client1) != ESP_OK){
    Serial.println("Failed to add peer.");
    return;
  }

  // Add Client2, Vidalia

  memcpy(client2.peer_addr, ESP_BLU_ADDR, 6);
  client2.channel = 0;
  client2.encrypt = false;

  if (esp_now_add_peer(&client2) != ESP_OK){
    Serial.println("Failed to add peer.");
    return;
  }


  
}

void loop() {

  if (Serial.available() > 0)
  {
    int serial_read = Serial.read();

    if (is_valid_status_byte(serial_read)){
      handle_serial_updates(serial_read);
    }
    
  }

}

void handle_serial_updates(int serial_byte) {
  switch (serial_byte) {
    case 16:
      handle_display_updates();
    //case 0xf0:
      //handle_servo_updates();
  }
}

bool is_valid_status_byte(int serial_byte) {
  
  
  int test_byte = serial_byte | 0b1111;
  test_byte = ~ 0b1111;
  //return is_data_in_array(UPDATE_TYPES, test_byte);

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
  uint8_t bytes_buffer[10];
  uint8_t new_bytes_to_send[11]; // the new bytes to send must ALWAYS be 1 more than the bytes buffer
  new_bytes_to_send[0] = 16;

  while (Serial.available() < 10);

  Serial.readBytes(bytes_buffer, 10);

  for (int i = 0; i < 10; i++){
    new_bytes_to_send[i+1] = bytes_buffer[i];
  }
  
  esp_now_send(0, (uint8_t *) &new_bytes_to_send, sizeof(new_bytes_to_send));
}

void handle_servo_updates(){
  char bytes_buffer[2] = {};
  // first byte is Control Number
  // second byte is the Control CHANGE
  Serial.readBytes(bytes_buffer, 2);

  int control = bytes_buffer[0];
  int change = bytes_buffer[1];

  ///

}

// callback when data is sent from Master to client1
void OnDataSent(const uint8_t *mac_addr, esp_now_send_status_t status) {
  Serial.println("Data sent.");
  char macStr[18];
  snprintf(macStr, sizeof(macStr), "%02x:%02x:%02x:%02x:%02x:%02x",
           mac_addr[0], mac_addr[1], mac_addr[2], mac_addr[3], mac_addr[4], mac_addr[5]);
  Serial.print("Last Packet Sent to: "); Serial.println(macStr);
  Serial.print("Last Packet Send Status: "); Serial.println(status == ESP_NOW_SEND_SUCCESS ? "Delivery Success" : "Delivery Fail");
}

void sendData(uint8_t data_to_send) {
  const uint8_t *peer_addr = client1.peer_addr;
  Serial.print("Sending: "); Serial.println(data_to_send);
  esp_err_t result = esp_now_send(0, (uint8_t *) &data_to_send, sizeof(data_to_send));
  Serial.print("Send Status: ");
  if (result == ESP_OK) {
    Serial.println("Success");
  } else if (result == ESP_ERR_ESPNOW_NOT_INIT) {
    // How did we get so far!!
    Serial.println("ESPNOW not Init.");
  } else if (result == ESP_ERR_ESPNOW_ARG) {
    Serial.println("Invalid Argument");
  } else if (result == ESP_ERR_ESPNOW_INTERNAL) {
    Serial.println("Internal Error");
  } else if (result == ESP_ERR_ESPNOW_NO_MEM) {
    Serial.println("ESP_ERR_ESPNOW_NO_MEM");
  } else if (result == ESP_ERR_ESPNOW_NOT_FOUND) {
    Serial.println("Peer not found.");
  } else {
    Serial.println("Not sure what happened");
  }
}

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