#!/bin/bash
# Connect Android device via Wireless Debugging
#
# Prerequisites: adb (Android SDK). On macOS: install Android Studio, then SDK is at
#   ~/Library/Android/sdk  →  adb is in platform-tools/
#
# On phone: Settings → Developer options → Wireless debugging (On).
#   PAIRING: tap "Pair device with pairing code" → use PAIRING_PORT and CODE below.
#   CONNECTION: on main "Wireless debugging" screen, note "IP address & port" (e.g. 192.168.1.111:43193).

# Use adb from Android SDK on macOS if present
if [[ -x "$HOME/Library/Android/sdk/platform-tools/adb" ]]; then
  export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"
fi
if ! command -v adb &>/dev/null; then
  echo "Error: adb not found. Install Android Studio and the Android SDK, then run this script again."
  echo "  https://developer.android.com/studio"
  exit 1
fi

PHONE_IP="192.168.1.111"
PAIRING_PORT="43193"
CONNECTION_PORT="43193"   # From main Wireless debugging screen: "IP address & port"
CODE="604216"

# Only pair if not already paired (pairing is one-time per PC)
echo "Step 1: Pairing (skip if already paired)..."
adb pair ${PHONE_IP}:${PAIRING_PORT} <<< "$CODE" 2>/dev/null || echo "  (pairing skipped or already done)"

echo ""
echo "Step 2: Connecting on port $CONNECTION_PORT..."
adb kill-server 2>/dev/null
sleep 1
adb connect ${PHONE_IP}:${CONNECTION_PORT}

echo ""
echo "Step 3: Devices..."
adb devices -l

echo ""
if adb devices | grep -q "${PHONE_IP}.*device$"; then
  echo "Device is connected. Run: flutter run"
else
  echo "Device offline or not found. On phone: open Wireless debugging (main screen)"
  echo "and set CONNECTION_PORT in this script to the port shown (e.g. 41234)."
fi
