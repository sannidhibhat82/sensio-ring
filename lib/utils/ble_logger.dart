/// Central logger for BLE raw hex data and events.
class BleLogger {
  static final List<String> _lines = [];
  static const int _maxLines = 500;

  static List<String> get lines => List.unmodifiable(_lines);

  static void log(String message) {
    final line = '[BLE] $message';
    _lines.add(line);
    if (_lines.length > _maxLines) _lines.removeAt(0);
    // ignore: avoid_print
    print(line);
  }

  static void logHex(String tag, List<int> bytes) {
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('-');
    log('$tag (${bytes.length} bytes): $hex');
  }

  /// Log data received FROM device: hex + decoded (ASCII if printable, else raw).
  static void logFromDevice(String source, List<int> bytes) {
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('-');
    final allPrintable = bytes.isNotEmpty && bytes.every((b) => b >= 0x20 && b <= 0x7E);
    final decoded = allPrintable
        ? String.fromCharCodes(bytes)
        : (bytes.length == 2
            ? 'raw=${(bytes[0] << 8) | bytes[1]} (temp=${((bytes[0] << 8) | bytes[1]) * 0.005}°C?)'
            : '${bytes.length} bytes');
    log('FROM DEVICE [$source] (${bytes.length} bytes) hex: $hex | decoded: $decoded');
  }

  static String getLogText() => _lines.join('\n');

  static void clear() => _lines.clear();
}
