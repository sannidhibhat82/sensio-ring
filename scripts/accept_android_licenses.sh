#!/bin/bash
# Accept Android SDK/NDK licenses by creating license files.
# SDK path: /usr/lib/android-sdk (requires sudo to write).

set -e

SDK="${ANDROID_HOME:-/usr/lib/android-sdk}"
LIC="${SDK}/licenses"

if [ ! -d "$SDK" ]; then
  echo "Android SDK not found at $SDK. Set ANDROID_HOME if needed."
  exit 1
fi

echo "Using SDK: $SDK"
echo "Creating licenses in $LIC (may need sudo)..."

# Create licenses dir and standard SDK/NDK license hashes (same as sdkmanager --licenses)
sudo mkdir -p "$LIC"
# Android SDK License
echo -e "\n24333f8a63b6825ea9c5514f83c2829b004d1fee" | sudo tee "$LIC/android-sdk-license" > /dev/null
echo -e "\n84831b9409646a918e30573bab4c9c91346d8abd" | sudo tee -a "$LIC/android-sdk-license" > /dev/null
# Android SDK Preview License
echo -e "\n84831b9409646a918e30573bab4c9c91346d8abd" | sudo tee "$LIC/android-sdk-preview-license" > /dev/null 2>/dev/null || true

echo "Done. Run: flutter run -d ZA222KYQ58"
