#include <Wire.h>
#include "Adafruit_SSD1306.h"
#include "Adafruit_GFX.h"
#include "MAX30102.h"
#include "heartRate.h"
#include "OneWire.h"
#include "DallasTemperature.h"
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include "PubSubClient.h"
#include "ArduinoJson.h"
#include "WiFiManager.h"
#include "ESP32Time.h"
#include "MAX30105.h"

MAX30102 particleSensor;

#define MAX_HISTORY 32
#define BUFFER_SIZE 100
#define SAMPLE_FREQ 25

volatile int BEATS = 0;         
volatile int FINGER_FLAG = 0;   
volatile int SPO2 = 0;          
volatile float TEMPERATURE = 0; 
unsigned long t_start;

void displayInfo() {
    if (FINGER_FLAG == 0) {
        return; 
    }
    Serial.println("链接人数：0")

    Serial.print("HRvalid: ");
    Serial.print(BEATS);
    Serial.print(" SPO2: ");
    Serial.print(SPO2);
    Serial.print(" Temperature: ");
    Serial.println(TEMPERATURE);
}

void timerCallback() {
    displayInfo();
}

void setup() {
    Serial.begin(115200);
    Wire.begin();

    if (!particleSensor.begin(Wire, I2C_SPEED_FAST)) {
        Serial.println("MAX30102 was not found. Please check wiring/power.");
        while (1);
    }

    particleSensor.setup(); 
    particleSensor.setPulseAmplitudeRed(0x0A); 
    particleSensor.setPulseAmplitudeGreen(0);  

    t_start = millis(); 
    Timer1.initialize(1000000); 
    Timer1.attachInterrupt(timerCallback);
}

void loop() {
    static int history[MAX_HISTORY];
    static int beats_history[MAX_HISTORY];
    static int history_size = 0;
    static int beats_history_size = 0;
    static bool beat = false;
    static int red_list[BUFFER_SIZE];
    static int ir_list[BUFFER_SIZE];
    static int buffer_size = 0;

    long irValue = particleSensor.getIR();
    long redValue = particleSensor.getRed();

    if (irValue < 50000) {
        FINGER_FLAG = 0; 
        return;
    } else {
        FINGER_FLAG = 1; 
    }

    history[history_size % MAX_HISTORY] = irValue;
    history_size++;

    int minima = history[0], maxima = history[0];
    for (int i = 1; i < MAX_HISTORY; i++) {
        if (history[i] < minima) minima = history[i];
        if (history[i] > maxima) maxima = history[i];
    }

    int threshold_on = (minima + maxima * 3) / 4;
    int threshold_off = (minima + maxima) / 2;

    if (!beat && irValue > threshold_on) {
        beat = true;
        unsigned long t_us = millis() - t_start;
        double t_s = t_us / 1000.0;
        double f = 1.0 / t_s;
        double bpm = f * 60.0;
        if (bpm < 500.0) {
            t_start = millis();
            beats_history[beats_history_size % MAX_HISTORY] = (int)bpm;
            beats_history_size++;
            int sum_beats = 0;
            for (int i = 0; i < MAX_HISTORY; i++) {
                sum_beats += beats_history[i];
            }
            BEATS = sum_beats / MAX_HISTORY;
        }
    }

    if (beat && irValue < threshold_off) {
        beat = false;
    }

    delay(20); 

    red_list[buffer_size % BUFFER_SIZE] = redValue;
    ir_list[buffer_size % BUFFER_SIZE] = irValue;
    buffer_size++;

    if (buffer_size >= BUFFER_SIZE) {
        int hr, hr_valid, spo2, spo2_valid;
        calc_hr_and_spo2(ir_list, red_list, &hr, &hr_valid, &spo2, &spo2_valid);
        if (spo2_valid) {
            SPO2 = spo2;
        }
        buffer_size = 0; 
    }

    TEMPERATURE = particleSensor.readTemperature();
}

void calc_hr_and_spo2(int *ir_data, int *red_data, int *hr, int *hr_valid, int *spo2, int *spo2_valid) {
    int ir_mean = 0;
    for (int i = 0; i < BUFFER_SIZE; i++) {
        ir_mean += ir_data[i];
    }
    ir_mean /= BUFFER_SIZE;

    int x[BUFFER_SIZE];
    for (int i = 0; i < BUFFER_SIZE; i++) {
        x[i] = ir_mean - ir_data[i];
    }

    for (int i = 0; i < BUFFER_SIZE - 4; i++) {
        int sum = 0;
        for (int j = i; j < i + 4; j++) {
            sum += x[j];
        }
        x[i] = sum / 4;
    }

    int n_th = 0;
    for (int i = 0; i < BUFFER_SIZE; i++) {
        n_th += x[i];
    }
    n_th /= BUFFER_SIZE;
    n_th = n_th < 30 ? 30 : (n_th > 60 ? 60 : n_th);

    int ir_valley_locs[BUFFER_SIZE] = {0};
    int n_peaks = find_peaks(x, BUFFER_SIZE, n_th, 4, 15, ir_valley_locs);

    if (n_peaks >= 2) {
        int peak_interval_sum = 0;
        for (int i = 1; i < n_peaks; i++) {
            peak_interval_sum += (ir_valley_locs[i] - ir_valley_locs[i - 1]);
        }
        peak_interval_sum /= (n_peaks - 1);
        *hr = SAMPLE_FREQ * 60 / peak_interval_sum;
        *hr_valid = 1;
    } else {
        *hr = -999;
        *hr_valid = 0;
    }

}

int find_peaks(int *x, int size, int min_height, int min_dist, int max_num, int *ir_valley_locs) {
    int n_peaks = 0;
    for (int i = 1; i < size - 1; i++) {
        if (x[i] > min_height && x[i] > x[i - 1]) {
            int n_width = 1;
            while (i + n_width < size - 1 && x[i] == x[i + n_width]) {
                n_width++;
            }
            if (x[i] > x[i + n_width] && n_peaks < max_num) {
                ir_valley_locs[n_peaks] = i;
                n_peaks++;
                i += n_width + 1;
            } else {
                i += n_width;
            }
        }
    }

    return n_peaks;
}
