/// BLE UUIDs and device constants for SENSIO Ring.
/// All communication: WRITE (with response) + NOTIFY.

class BleConstants {
  BleConstants._();

  static const String deviceNameFilter = 'SENSIO';
  static const String deviceName = 'SENSIO Ring';
  static const int requestedMtu = 450;

  // Service UUIDs
  static const String serviceUuidVitals =
      'a0262760-08c2-11e1-9073-0e8ac72e1234';
  static const String serviceUuidCustom =
      '4e771a15-2665-cf92-9073-8c64a4ab357';

  // Characteristic UUIDs
  static const String charUuidVitals =
      'a0262760-08c2-11e1-9073-0e8ac72e0001';
  static const String charUuidCustom =
      '48837cb0-b733-7c24-31b7-222222222222';

  // CCCD descriptor for enabling notifications
  static const String cccdUuid = '00002902-0000-1000-8000-00805f9b34fb';

  // Temperature conversion: raw (byte1<<8|byte2) * 0.005 = °C
  static const double tempScaleFactor = 0.005;

  // STS40 / GETVITALS temperature: (byte + 200) / 10 = °C
  static const int tempOffset = 200;
  static const double tempDivisor = 10.0;

  // ECG R-R interval: ((RR[i+1]-RR[i])/128)*1000 ms
  static const int ecgRRBaseHz = 128;
  static const int ecgRRMsMultiplier = 1000;

  // HRM_HRV R-R: ms = (RR * 0.04) / 60
  static const double hrmRrScale = 0.04;
  static const double hrmRrDivisor = 60.0;

  // Sensor Hub: 44 bytes per sample, 30 samples per batch
  static const int sensorHubSampleBytes = 44;
  static const int sensorHubSamplesPerBatch = 30;
  static const int sensorHubPpgBytes = 18;
  static const int sensorHubAccOffset = 18;
  static const int sensorHubAccBytes = 6;
}
