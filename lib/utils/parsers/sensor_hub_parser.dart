import '../../models/sensor_hub_sample.dart';
import '../ble_constants.dart';

/// Parses Sensor Hub raw: 44 bytes per sample.
class SensorHubParser {
  static SensorHubSample? parseSample(List<int> bytes, [int start = 0]) {
    if (start + 44 > bytes.length) return null;
    final b = bytes;
    final i = start;

    final greenPd1 = _read24(b, i);
    final greenPd2 = _read24(b, i + 3);
    final irPd1 = _read24(b, i + 6);
    final irPd2 = _read24(b, i + 9);
    final redPd1 = _read24(b, i + 12);
    final redPd2 = _read24(b, i + 15);
    final accX = _read16(b, i + 18);
    final accY = _read16(b, i + 20);
    final accZ = _read16(b, i + 22);
    final operatingMode = b[i + 24];
    final hr = _read16(b, i + 25);
    final hrConf = b[i + 27];
    final rr = _read16(b, i + 28);
    final rrConf = b[i + 30];
    final activityClass = b[i + 31];
    final r = _read16(b, i + 32);
    final spo2Conf = b[i + 34];
    final spo2 = _read16(b, i + 35);
    final percentComplete = b[i + 37];
    final lowSignalQualityFlag = b[i + 38];
    final motionFlag = b[i + 39];
    final lowPiFlag = b[i + 40];
    final unreliableFlag = b[i + 41];
    final scdContactState = b[i + 42];

    return SensorHubSample(
      greenPd1: greenPd1,
      greenPd2: greenPd2,
      irPd1: irPd1,
      irPd2: irPd2,
      redPd1: redPd1,
      redPd2: redPd2,
      accX: accX,
      accY: accY,
      accZ: accZ,
      operatingMode: operatingMode,
      hr: hr,
      hrConf: hrConf,
      rr: rr,
      rrConf: rrConf,
      activityClass: activityClass,
      r: r,
      spo2Conf: spo2Conf,
      spo2: spo2,
      percentComplete: percentComplete,
      lowSignalQualityFlag: lowSignalQualityFlag,
      motionFlag: motionFlag,
      lowPiFlag: lowPiFlag,
      unreliableFlag: unreliableFlag,
      scdContactState: scdContactState,
      timestamp: DateTime.now(),
    );
  }

  static List<SensorHubSample> parseBatch(List<int> bytes) {
    final samples = <SensorHubSample>[];
    final sampleBytes = BleConstants.sensorHubSampleBytes;
    final limit = bytes.length - (bytes.length % sampleBytes);
    for (int i = 0; i < limit; i += sampleBytes) {
      final s = parseSample(bytes, i);
      if (s != null) samples.add(s);
    }
    return samples;
  }

  static int _read24(List<int> b, int i) {
    return (b[i] << 16) | (b[i + 1] << 8) | b[i + 2];
  }

  static int _read16(List<int> b, int i) {
    return (b[i] << 8) | b[i + 1];
  }
}
