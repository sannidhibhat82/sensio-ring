#!/bin/bash
# Install Android build-tools and platform so Flutter can build for your phone.
# Requires: Java (JDK). Install from https://adoptium.net/ (Temurin) if needed.
#
# After this runs successfully, run: flutter run -d <device_id>

set -e
ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
CMD="$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager"

# Find Java on macOS (JAVA_HOME, then java_home, then common paths)
if [[ -z "$JAVA_HOME" ]]; then
  JAVA_HOME=$(/usr/libexec/java_home 2>/dev/null) || true
fi
if [[ -z "$JAVA_HOME" ]]; then
  for d in "$HOME/Library/Java/JavaVirtualMachines/"*"/Contents/Home" "/Library/Java/JavaVirtualMachines/"*"/Contents/Home"; do
    [[ -x "$d/bin/java" ]] 2>/dev/null && export JAVA_HOME="$d" && break
  done
fi
[[ -n "$JAVA_HOME" ]] && export PATH="$JAVA_HOME/bin:$PATH"

if ! command -v java &>/dev/null; then
  echo "Java is required."
  echo ""
  echo "Install a JDK (one-time):"
  echo "  1. Open: https://adoptium.net/temurin/releases/?version=17&os=mac&arch=aarch64"
  echo "  2. Download the .pkg (macOS aarch64), run it, then open a new terminal."
  echo "  Or install from: https://adoptium.net/"
  echo ""
  echo "Then run this script again: ./scripts/install_android_buildtools.sh"
  exit 1
fi
if [[ ! -x "$CMD" ]]; then
  echo "Android cmdline-tools not found at $CMD"
  exit 1
fi

export ANDROID_HOME
echo "Accepting licenses..."
yes | "$CMD" --licenses 2>/dev/null || true
echo "Installing build-tools and platform (android-35)..."
"$CMD" "build-tools;35.0.0" "platforms;android-35"
echo "Done. Run: flutter run -d ZA222KYQ58"
echo "Or: flutter run   (with phone connected)"
echo "Add to PATH for adb: export PATH=\"\$ANDROID_HOME/platform-tools:\$PATH\""
