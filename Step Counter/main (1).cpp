#include <Arduino.h>
#include <HttpClient.h>
#include <WiFi.h>
#include <inttypes.h>
#include <stdio.h>

#include "esp_system.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "nvs.h"
#include "nvs_flash.h"

#include "Wire.h"
#include "SparkFunLSM6DSO.h"

LSM6DSO myIMU;

#define LED_PIN 32

#define CALIBRATION_STATE 0
#define FUNCTIONAL_STATE 1
#define LEFT_BUTTON 0

u_int8_t state;

u_long timer;

float x_accel;
float y_accel;
float z_accel;

int step_count;

// This example downloads the URL "http://arduino.cc/"
char ssid[50];  // your network SSID (name)
char pass[50];  // your network password (use for WPA, or use
// as key for WEP)
// Name of the server we want to connect to
const char kHostname[] = "54.177.76.74";
// Number of milliseconds to wait without receiving any data before we give up
const int kNetworkTimeout = 30 * 1000;
// Number of milliseconds to wait if no data is available before trying again
const int kNetworkDelay = 1000;
void nvs_access() {
	// Initialize NVS
	esp_err_t err = nvs_flash_init();
	if (err == ESP_ERR_NVS_NO_FREE_PAGES ||
			err == ESP_ERR_NVS_NEW_VERSION_FOUND) {
		// NVS partition was truncated and needs to be erased
		// Retry nvs_flash_init
		ESP_ERROR_CHECK(nvs_flash_erase());
		err = nvs_flash_init();
	}
	ESP_ERROR_CHECK(err);
	// Open
	Serial.printf("\n");
	Serial.printf("Opening Non-Volatile Storage (NVS) handle... ");
	nvs_handle_t my_handle;
	err = nvs_open("storage", NVS_READWRITE, &my_handle);
	if (err != ESP_OK) {
		Serial.printf("Error (%s) opening NVS handle!\n", esp_err_to_name(err));
	} else {
		Serial.printf("Done\n");
		Serial.printf("Retrieving SSID/PASSWD\n");
		size_t ssid_len;
		size_t pass_len;
		err = nvs_get_str(my_handle, "ssid", ssid, &ssid_len);
		err |= nvs_get_str(my_handle, "pass", pass, &pass_len);
		switch (err) {
			case ESP_OK:
				Serial.printf("Done\n");
				// Serial.printf("SSID = %s\n", ssid);
				// Serial.printf("PASSWD = %s\n", pass);
				break;
			case ESP_ERR_NVS_NOT_FOUND:
				Serial.printf("The value is not initialized yet!\n");
				break;
			default:
				Serial.printf("Error (%s) reading!\n", esp_err_to_name(err));
		}
	}
	// Close
	nvs_close(my_handle);
}
void setup() {
	Serial.begin(9600);
	delay(1000);
	// Retrieve SSID/PASSWD from flash before anything else
	nvs_access();
	// We start by connecting to a WiFi network
	delay(1000);
	Serial.println();
	Serial.println();
	Serial.print("Connecting to ");
	Serial.println(ssid);
	Serial.println("With password: " + String(pass));
	Serial.println(WiFi.macAddress());
	WiFi.begin(ssid, pass);
	while (WiFi.status() != WL_CONNECTED) {
		delay(500);
		Serial.print(".");
	}
	Serial.println("");
	Serial.println("WiFi connected");
	Serial.println("IP address: ");
	Serial.println(WiFi.localIP());
	Serial.println("MAC address: ");
	Serial.println(WiFi.macAddress());

	delay(500);

	state = CALIBRATION_STATE;
	step_count = 0;

	Wire.begin();
	delay(10);
	if (myIMU.begin())
		Serial.println("Ready.");
	else {
		Serial.println("Could not connect to IMU.");
		Serial.println("Freezing");
	}

	if (myIMU.initialize(BASIC_SETTINGS)) Serial.println("Loaded Settings.");
	timer = millis();
}

void loop() {
	switch(state) {
    case CALIBRATION_STATE:
      if (millis() - timer >= 10000) {
        state = FUNCTIONAL_STATE;
        timer = millis();
        x_accel = abs(x_accel);
        y_accel = abs(y_accel);
        z_accel = abs(z_accel);
      }

      x_accel = myIMU.readFloatAccelX();
      y_accel = myIMU.readFloatAccelY();
      z_accel = myIMU.readFloatAccelZ();
      break;
    
    case FUNCTIONAL_STATE:
		if (millis() - timer >= 200 && abs(z_accel - myIMU.readFloatAccelZ()) > 1) {
			int err = 0;
			WiFiClient c;
			HttpClient http(c);

			step_count++;
			Serial.println(step_count);
			String steps = "/" + String(step_count);

			err = http.post(kHostname, 5000, &steps[0]);

			Serial.println(err);
			timer = millis();
		}
		break;
  	}
}