# Set up Java for Flutter Android builds

Your device is connected (`adb devices` shows `device`). The build failed because Java is not installed or `JAVA_HOME` is not set.

## 1. Install JDK 17

Run in terminal:

```bash
sudo apt update
sudo apt install -y openjdk-17-jdk
```

## 2. Set JAVA_HOME (current terminal session)

```bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH="$JAVA_HOME/bin:$PATH"
```

(On some systems the path is `java-17-openjdk-arm64` or just `java-17-openjdk-*`; check with `ls /usr/lib/jvm`.)

## 3. Make it permanent (optional)

Add to `~/.bashrc` or `~/.profile`:

```bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH="$JAVA_HOME/bin:$PATH"
```

Then run `source ~/.bashrc`.

## 4. Run the app

```bash
cd /home/sannidhi/flutter/sensio-ring
flutter run -d ZA222KYQ58
```

Or just `flutter run` and pick the device.
