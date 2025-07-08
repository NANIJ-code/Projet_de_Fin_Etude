#include <WiFi.h>
#include <FirebaseESP32.h>
#include <Arduino.h>

// Identifiants WiFi
const char* ssid = "fono";
const char* password = "12345678";

// Configuration Firebase
#define FIREBASE_HOST "https://jadolc-default-rtdb.europe-west1.firebasedatabase.app"
#define FIREBASE_AUTH "AIzaSyBoDE4lCtr5-3SInqtkNZ7Aq0rAdGpzdhQ"

// Broches ADC pour ESP32
const int ECG_PIN = 34;  // GPIO34 (ADC1_CH6)
const int EEG_PIN = 35;  // GPIO35 (ADC1_CH7)

// Paramètres ADC
const float REF_VOLTAGE = 3.3;   // Tension de référence
const int ADC_RESOLUTION = 4095; // 12 bits
const float SAMPLE_RATE = 100.0; // 100 Hz
const int SAMPLE_DELAY_US = 10000; // 1000ms / 100Hz = 10ms = 10000us

// Filtres ECG
const float ECG_LP_CUTOFF = 40.0; // Fréquence de coupure passe-bas
const float ECG_HP_CUTOFF = 0.5;  // Fréquence de coupure passe-haut
float ecgLP = 0.0;                // Sortie passe-bas
float ecgHP = 0.0;                // Sortie passe-haut
float prevEcgRaw = 0.0;           // Valeur précédente pour passe-haut

// Filtres EEG
const float EEG_LP_CUTOFF = 30.0; // Fréquence de coupure passe-bas
const float EEG_HP_CUTOFF = 0.5;  // Fréquence de coupure passe-haut
float eegLP = 0.0;                // Sortie passe-bas
float eegHP = 0.0;                // Sortie passe-haut
float prevEegRaw = 0.0;           // Valeur précédente pour passe-haut

// Coefficients de filtrage
float ecgAlphaLP = 0.0;
float ecgAlphaHP = 0.0;
float eegAlphaLP = 0.0;
float eegAlphaHP = 0.0;

// Statistiques
unsigned long sampleCount = 0;
unsigned long startTime = 0;
unsigned long lastDisplayTime = 0;
const int DISPLAY_INTERVAL = 100; // Affichage toutes les 100ms (10 Hz)

// Firebase
FirebaseData fbdo;

void setup() {
  Serial.begin(115200);
  analogReadResolution(12);

  // Connexion WiFi
  Serial.println("Démarrage de la connexion WiFi...");
  WiFi.begin(ssid, password);
  int attempts = 0;
  const int maxAttempts = 20;
  while (WiFi.status() != WL_CONNECTED && attempts < maxAttempts) {
    delay(1000);
    Serial.print("Tentative ");
    Serial.print(attempts + 1);
    Serial.print("/"); Serial.print(maxAttempts);
    Serial.print(" - État WiFi: ");
    switch (WiFi.status()) {
      case WL_NO_SSID_AVAIL:
        Serial.println("SSID non trouvé");
        break;
      case WL_CONNECT_FAILED:
        Serial.println("Échec de la connexion (mot de passe incorrect ?)");
        break;
      case WL_CONNECTION_LOST:
        Serial.println("Connexion perdue");
        break;
      case WL_DISCONNECTED:
        Serial.println("Déconnecté");
        break;
      default:
        Serial.print("Code d'état: ");
        Serial.println(WiFi.status());
        break;
    }
    attempts++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("Connecté au WiFi !");
    Serial.print("Adresse IP: ");
    Serial.println(WiFi.localIP());
    Serial.print("Puissance du signal (RSSI): ");
    Serial.print(WiFi.RSSI());
    Serial.println(" dBm");
  } else {
    Serial.println("Échec de la connexion WiFi après 20 tentatives.");
    return;
  }

  // Initialisation Firebase
  Serial.println("Initialisation de Firebase...");
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  Firebase.reconnectWiFi(true);

  if (Firebase.ready()) {
    Serial.println("Firebase initialisé avec succès !");
  } else {
    Serial.println("Échec de l'initialisation Firebase.");
    Serial.print("Erreur: ");
    Serial.println(fbdo.errorReason());
  }

  // Calcul des coefficients alpha
  ecgAlphaLP = calculateAlphaLP(ECG_LP_CUTOFF);
  ecgAlphaHP = calculateAlphaHP(ECG_HP_CUTOFF);
  eegAlphaLP = calculateAlphaLP(EEG_LP_CUTOFF);
  eegAlphaHP = calculateAlphaHP(EEG_HP_CUTOFF);

  // Lecture initiale pour initialiser les filtres
  float initValue = readVoltage(ECG_PIN);
  ecgLP = initValue;
  ecgHP = initValue;
  prevEcgRaw = initValue;

  initValue = readVoltage(EEG_PIN);
  eegLP = initValue;
  eegHP = initValue;
  prevEegRaw = initValue;

  startTime = millis();

  Serial.println("Démarrage du système de surveillance physiologique...");
  Serial.println("Configuration:");
  Serial.print("  ECG: HP="); Serial.print(ECG_HP_CUTOFF);
  Serial.print("Hz, LP="); Serial.print(ECG_LP_CUTOFF); Serial.println("Hz");
  Serial.print("  EEG: HP="); Serial.print(EEG_HP_CUTOFF);
  Serial.print("Hz, LP="); Serial.print(EEG_LP_CUTOFF); Serial.println("Hz");
  Serial.println("Broches utilisées:");
  Serial.print("  ECG: GPIO"); Serial.println(ECG_PIN);
  Serial.print("  EEG: GPIO"); Serial.println(EEG_PIN);
  Serial.println("Format des données envoyé à Firebase:");
  Serial.println("  ecgRaw,ecgFiltered,eegRaw,eegFiltered,timestamp");
  Serial.println("Format d'affichage série:");
  Serial.println("  Temps(ms),ECG_Raw(V),ECG_Filtered(V),EEG_Raw(V),EEG_Filtered(V)");
  Serial.println("Attente de la stabilisation des signaux...");
  delay(1000); // Stabilisation
}

void loop() {
  static unsigned long lastSampleTime = 0;
  unsigned long currentTime = micros();

  // Échantillonnage à 100 Hz (toutes les 10ms)
  if (currentTime - lastSampleTime >= SAMPLE_DELAY_US) {
    lastSampleTime += SAMPLE_DELAY_US; // Maintien de la précision temporelle
    sampleCount++;

    // Lecture des signaux bruts
    float ecgRaw = readVoltage(ECG_PIN);
    float eegRaw = readVoltage(EEG_PIN);

    // Filtrage ECG
    ecgHP = ecgAlphaHP * (ecgHP + ecgRaw - prevEcgRaw);
    prevEcgRaw = ecgRaw;
    ecgLP = ecgAlphaLP * ecgHP + (1 - ecgAlphaLP) * ecgLP;

    // Filtrage EEG
    eegHP = eegAlphaHP * (eegHP + eegRaw - prevEegRaw);
    prevEegRaw = eegRaw;
    eegLP = eegAlphaLP * eegHP + (1 - eegAlphaLP) * eegLP;

    // Affichage des signaux dans le Moniteur Série (10 Hz)
    if (millis() - lastDisplayTime >= DISPLAY_INTERVAL) {
      lastDisplayTime = millis();
      Serial.print(millis());
      Serial.print(",");
      Serial.print(ecgRaw, 3);
      Serial.print(",");
      Serial.print(ecgLP, 3);
      Serial.print(",");
      Serial.print(eegRaw, 3);
      Serial.print(",");
      Serial.print(eegLP, 3);
      Serial.println();
    }

    // Créer un objet JSON pour Firebase
    FirebaseJson json;
    json.set("ecgRaw", ecgRaw);
    json.set("ecgFiltered", ecgLP);
    json.set("eegRaw", eegRaw);
    json.set("eegFiltered", eegLP);
    json.set("timestamp", String(millis()));

    // Envoyer à Firebase Realtime Database
    String path = "/signals/patient123/data/" + String(millis());
    if (Firebase.ready() && WiFi.status() == WL_CONNECTED) {
      Serial.println("Tentative d'envoi à Firebase...");
      if (Firebase.pushJSON(fbdo, path, json)) {
        Serial.println("Données envoyées à Firebase");
      } else {
        Serial.print("Erreur d'envoi: ");
        Serial.println(fbdo.errorReason());
      }
    } else {
      Serial.println("Firebase ou WiFi non prêt.");
      Serial.print("Firebase.ready(): ");
      Serial.println(Firebase.ready());
      Serial.print("WiFi.status(): ");
      Serial.println(WiFi.status());
    }

    // Affichage périodique des statistiques (toutes les 500 échantillons)
    if (sampleCount % 500 == 0) {
      unsigned long elapsed = millis() - startTime;
      float actualRate = 1000.0 * sampleCount / elapsed;

      Serial.print("\n--- Statistiques --- [");
      Serial.print(elapsed / 1000.0, 1);
      Serial.println("s]");
      Serial.print("Taux d'échantillonnage: ");
      Serial.print(actualRate, 1);
      Serial.println(" Hz");
      Serial.print("ECG: ");
      Serial.print(ecgLP, 3);
      Serial.print(" V  |  EEG: ");
      Serial.print(eegLP, 3);
      Serial.println(" V");
      Serial.println("------------------------");
    }
  }
}

float readVoltage(int pin) {
  // Moyenne de plusieurs lectures pour réduire le bruit
  const int numSamples = 8;
  long sum = 0;
  for (int i = 0; i < numSamples; i++) {
    sum += analogRead(pin);
    delayMicroseconds(100); // Court délai pour stabilité
  }
  float raw = sum / (float)numSamples;
  return (raw * REF_VOLTAGE) / ADC_RESOLUTION;
}

float calculateAlphaLP(float cutoff) {
  // Coefficient alpha pour filtre passe-bas
  float dt = 1.0 / SAMPLE_RATE;
  float rc = 1.0 / (2.0 * PI * cutoff);
  return dt / (dt + rc);
}

float calculateAlphaHP(float cutoff) {
  // Coefficient alpha pour filtre passe-haut
  float rc = 1.0 / (2.0 * PI * cutoff);
  float dt = 1.0 / SAMPLE_RATE;
  return rc / (rc + dt);
}