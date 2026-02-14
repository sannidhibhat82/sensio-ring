#!/bin/bash
# Connect Android device via Wireless Debugging
#
# Prerequisites: sudo apt install adb
#
# Two different ports on the phone:
#   PAIRING_PORT  = from "Pair device with pairing code" dialog (you already used 37233)
#   CONNECTION_PORT = from main "Wireless debugging" screen: "IP address & port" (e.g. 41234)
# If you see "offline" or "failed to connect", set CONNECTION_PORT from the main screen.

PHONE_IP="192.168.1.13"
PAIRING_PORT="37233"
CONNECTION_PORT="37233"   # <-- CHANGE THIS: open Wireless debugging (main screen), note the port shown there
CODE="248775"

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
if adb devices | grep -q "192.168.1.13.*device$"; then
  echo "Device is connected. Run: flutter run"
else
  echo "Device offline or not found. On phone: open Wireless debugging (main screen)"
  echo "and set CONNECTION_PORT in this script to the port shown (e.g. 41234)."
fi
