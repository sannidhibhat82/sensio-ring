#!/bin/bash
# Make Android SDK writable so Gradle can install NDK and other components.
# Run once: ./scripts/make_sdk_writable.sh

SDK="${ANDROID_HOME:-/usr/lib/android-sdk}"
if [ ! -d "$SDK" ]; then
  echo "Android SDK not found at $SDK"
  exit 1
fi
echo "Making $SDK writable for $(whoami)..."
sudo chown -R "$(whoami):$(id -gn)" "$SDK"
echo "Done. Run: flutter run -d ZA222KYQ58"
