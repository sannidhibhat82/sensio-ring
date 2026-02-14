# SENSIO Ring – Flutter BLE App

Production-ready Flutter application for the **SENSIO Ring** BLE wearable. Built with **flutter_blue_plus**, null safety, and a clean architecture.

## Requirements

- Flutter SDK (stable, 3.x)
- Android SDK (min 21, target 34)
- Physical SENSIO Ring device or BLE-capable Android device for testing

## Project structure

```
lib/
├── main.dart
├── models/           # Data models (TemperatureReading, EcgData, HrmHrvData, etc.)
├── screens/          # Home, Scan & Connect, and feature tabs
│   └── tabs/         # Temperature, ECG, HR/HRV, IMU, Sensor Hub, Vitals
├── services/          # BleService (singleton)
├── utils/             # BLE constants, logger, permission helper
│   └── parsers/       # TemperatureParser, EcgParser, ImuParser, PpgParser, etc.
└── widgets/           # Hex debug bottom sheet, etc.
```

## Setup and run

1. **Clone / open project**
   ```bash
   cd sensio-ring
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Android**
   - Permissions for BLE (BLUETOOTH_SCAN, BLUETOOTH_CONNECT, ACCESS_FINE_LOCATION) are in `android/app/src/main/AndroidManifest.xml`.
   - Run on device or emulator with BLE:
   ```bash
   flutter run
   ```

4. **iOS (optional)**  
   Add in `ios/Runner/Info.plist`:
   - `NSBluetoothAlwaysUsageDescription`
   - `NSBluetoothPeripheralUsageDescription`  
   Then run: `flutter run` (iOS device with BLE).

## BLE device details

- **Device name:** SENSIO  
- **Example address:** DD:C4:92:C0:80:B3  

### Services and characteristics

| Use case           | Service UUID                          | Characteristic UUID                         |
|--------------------|----------------------------------------|---------------------------------------------|
| Vitals (temp, SigMot, GETVITALS, get_hr, get_hrv) | `a0262760-08c2-11e1-9073-0e8ac72e1234` | `a0262760-08c2-11e1-9073-0e8ac72e0001`       |
| Custom (ECG, HRM_HRV, IMU, Sensor Hub, STS40, etc.) | `4e771a15-2665-cf92-9073-8c64a4ab357` | `48837cb0-b733-7c24-31b7-222222222222`       |

All writes use **WRITE with response**; data is received via **NOTIFY** (CCCD 0x2902). Commands are sent as **UTF-8** strings.

## Features implemented

1. **Scan & connect** – Scan for "SENSIO", connect, discover services, request MTU (450), subscribe to notifications.
2. **Temperature** – `STARTTEMP` / `STOPTEMP` on vitals char; parse `raw = (byte1<<8|byte2)`, `°C = raw * 0.005`.
3. **STS40** – `STARTSTS40` / `STOPSTS40` on custom char.
4. **SigMot** – Send `sigmot` on vitals char; notifications = array of motion counts per 30 s.
5. **Sensor Hub (PPG + ACC)** – `STARTSHRD` / `STOPSHRD`; 44 bytes/sample, 30 samples/batch; parse PPG (18 bytes) and accel (bytes 18–23).
6. **ECG** – `STARTECG:N` or `STARTECG_F:100`, `STOPECG`; ECG packets >200 bytes, HR/HRV <100 bytes, Z = 4 bytes; R-R formula `((RR[i+1]-RR[i])/128)*1000` ms.
7. **HRM + HRV** – `HRM_HRV` / `STOPHRM_HRV`; first byte = error code, then 384 bytes PPG, byte 385 = HR, 386 = RMSSD, rest = R-R.
8. **IMU** – `STARTIMU:X1_X2_X3_X4`, `STOPIMU`; optional `STARTACC:N_M` / `STOPACC`, `STARTBMM` / `STOPBMM`; big-endian, 2’s complement, scale factors.
9. **GETVITALS** – `GETVITALS` on vitals char; first frame 4 bytes (counts), then chunks up to 60 bytes (SigMot, Steps, Temp, HR); temp = `(byte+200)/10` °C.

## Testing with nRF Connect

1. Install **nRF Connect for Mobile** (Android/iOS).
2. Scan and connect to the SENSIO device.
3. Find the two services above and enable notifications on both characteristics.
4. In the app, connect to the same device; use **Scan & Connect** and select the SENSIO device.
5. Use the in-app **Hex Debug** (bug icon on home) to compare raw notifications with nRF Connect (e.g. same hex after sending the same command).

### Example commands (nRF or app)

- Vitals characteristic (write): `STARTTEMP`, `STOPTEMP`, `sigmot`, `GETVITALS`, `get_hr`, `get_hrv`.
- Custom characteristic (write): `STARTSTS40`, `STOPSTS40`, `STARTSHRD`, `STOPSHRD`, `STARTECG:200`, `STOPECG`, `HRM_HRV`, `STOPHRM_HRV`, `STARTIMU:0x08_0x01_0x01_0x0`, `STOPIMU`, etc.

## Architecture notes

- **BleService** – Singleton; holds device, vitals/custom characteristics, and broadcast streams for notifications.
- **Parsers** – Stateless; take raw bytes and return models (e.g. `TemperatureParser.parse`, `EcgParser.parse`, `PpgParser.parse`).
- **Reconnection** – Use `BleService.instance.reconnect()` (e.g. after connection lost).
- **Disconnect** – Use `BleService.instance.disconnect()`; unsubscribes and disconnects gracefully.

## License

Proprietary / internal use as required.
