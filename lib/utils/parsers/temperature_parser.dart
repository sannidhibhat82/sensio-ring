import '../../models/temperature_reading.dart';
import '../ble_constants.dart';

/// Parses temperature notifications.
/// Format: raw = (byte1 << 8) | byte2, temperature = raw * 0.005 °C
/// Device may echo commands (e.g. "STARTTEMP") as notifications — ignore those.
class TemperatureParser {
  /// True if bytes look like an ASCII command echo (e.g. STARTTEMP, STOPTEMP).
  static bool _isCommandEcho(List<int> bytes) {
    if (bytes.length < 6 || bytes.length > 16) return false;
    return bytes.every((b) => b >= 0x20 && b <= 0x7E);
  }

  /// First 2 bytes must not be both printable ASCII (else we'd parse "ST" from STARTTEMP).
  static bool _firstTwoBytesLookLikeData(List<int> bytes) {
    if (bytes.length < 2) return false;
    final a = bytes[0], b = bytes[1];
    return !(a >= 0x20 && a <= 0x7E && b >= 0x20 && b <= 0x7E);
  }

  /// Parse one temperature from 2 bytes (big-endian). Tries bytes 0-1, then 2-3 if length >= 4.
  static TemperatureReading? parse(List<int> bytes) {
    if (bytes.length < 2) return null;
    if (_isCommandEcho(bytes)) return null;

    int raw;
    if (bytes.length >= 2 && _firstTwoBytesLookLikeData(bytes)) {
      raw = (bytes[0] << 8) | bytes[1];
    } else if (bytes.length >= 4 && _firstTwoBytesLookLikeData(bytes.sublist(2, 4))) {
      raw = (bytes[2] << 8) | bytes[3];
    } else {
      return null;
    }

    final celsius = raw * BleConstants.tempScaleFactor;
    return TemperatureReading(
      celsius: celsius,
      raw: raw,
      timestamp: DateTime.now(),
    );
  }

  /// STS40 / GETVITALS temperature: (byte + 200) / 10 = °C
  static double sts40OrVitalsCelsius(int byte) {
    return (byte + BleConstants.tempOffset) / BleConstants.tempDivisor;
  }
}
