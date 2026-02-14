#!/bin/bash
# Run Flutter on Android with IPv4 preferred (avoids Java DNS/network issues in some environments).
cd "$(dirname "$0")/.."
export GRADLE_OPTS="-Djava.net.preferIPv4Stack=true"
exec flutter run -d ZA222KYQ58 "$@"
