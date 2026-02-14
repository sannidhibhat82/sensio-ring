import '../../models/imu_data.dart';

class ImuParser {
  static const double scaleAcc4G = 0.122;
  static const double scaleGyro250 = 0.00762;

  static List<ImuSample> parseImu(List<int> bytes) {
    final samples = <ImuSample>[];
    for (int i = 0; i + 11 < bytes.length; i += 12) {
      final ax = _readBigEndianSigned16(bytes, i);
      final ay = _readBigEndianSigned16(bytes, i + 2);
      final az = _readBigEndianSigned16(bytes, i + 4);
      final gx = _readBigEndianSigned16(bytes, i + 6);
      final gy = _readBigEndianSigned16(bytes, i + 8);
      final gz = _readBigEndianSigned16(bytes, i + 10);
      samples.add(ImuSample(
        accX: ax * scaleAcc4G,
        accY: ay * scaleAcc4G,
        accZ: az * scaleAcc4G,
        gyroX: gx * scaleGyro250,
        gyroY: gy * scaleGyro250,
        gyroZ: gz * scaleGyro250,
        timestamp: DateTime.now(),
      ));
    }
    return samples;
  }

  static List<AccelSample> parseAcc(List<int> bytes, {String range = '4G'}) {
    double scale = 0.122;
    if (range == '2G') scale = 0.061;
    if (range == '8G') scale = 0.244;
    if (range == '16G') scale = 0.488;
    final samples = <AccelSample>[];
    for (int i = 0; i + 5 < bytes.length; i += 6) {
      final x = _readLittleEndianSigned16(bytes, i);
      final y = _readLittleEndianSigned16(bytes, i + 2);
      final z = _readLittleEndianSigned16(bytes, i + 4);
      samples.add(AccelSample(
        x: x * scale,
        y: y * scale,
        z: z * scale,
        timestamp: DateTime.now(),
      ));
    }
    return samples;
  }

  static List<MagSample> parseBmm(List<int> bytes) {
    final samples = <MagSample>[];
    for (int i = 0; i + 11 < bytes.length; i += 12) {
      final x = _readBigEndianSigned32(bytes, i);
      final y = _readBigEndianSigned32(bytes, i + 4);
      final z = _readBigEndianSigned32(bytes, i + 8);
      samples.add(MagSample(
        x: x.toDouble(),
        y: y.toDouble(),
        z: z.toDouble(),
        timestamp: DateTime.now(),
      ));
    }
    return samples;
  }

  static int _readBigEndianSigned16(List<int> b, int i) {
    final u = (b[i] << 8) | b[i + 1];
    return u > 32767 ? u - 65536 : u;
  }

  static int _readLittleEndianSigned16(List<int> b, int i) {
    final u = b[i] | (b[i + 1] << 8);
    return u > 32767 ? u - 65536 : u;
  }

  static int _readBigEndianSigned32(List<int> b, int i) {
    final u = (b[i] << 24) | (b[i + 1] << 16) | (b[i + 2] << 8) | b[i + 3];
    return u > 2147483647 ? u - 4294967296 : u;
  }
}
