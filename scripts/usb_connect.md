# Connect Android device via USB

## 1. On your phone

1. **Enable Developer options**
   - **Settings** → **About phone** → tap **Build number** 7 times until you see "You are now a developer".

2. **Enable USB debugging**
   - **Settings** → **Developer options** → turn **USB debugging** **On**.

3. **Connect the USB cable** from phone to computer.

4. When the phone shows **"Allow USB debugging?"**, tap **Allow** (and optionally "Always allow from this computer").

---

## 2. On your computer

Check that the device is detected:

```bash
adb devices
```

You should see your device with status `device` (not `unauthorized` or `offline`).

List devices for Flutter:

```bash
flutter devices
```

---

## 3. Run the app

```bash
cd /home/sannidhi/flutter/sensio-ring
flutter run
```

If more than one device is connected, pick the Android device when prompted, or specify it:

```bash
flutter run -d <device_id>
```

---

## Troubleshooting

| Issue | What to do |
|-------|------------|
| Device shows **unauthorized** | On the phone, tap "Allow" on the USB debugging prompt. If you already denied it, unplug USB, revoke in Developer options, then plug in again. |
| Device not listed | Try another USB cable (some are charge-only). Install/update USB drivers if needed (manufacturer site or Android SDK). |
| **No supported devices** (Flutter) | Run `flutter doctor -v` and install Android SDK / Android Studio if Android toolchain is missing. |
